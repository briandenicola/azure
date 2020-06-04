param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("APP01_Subscription", "APP02_Subscription", "Core_Subscription")]
    [string] $SubscriptionName = "APP01_Subscription",

    [Parameter(Mandatory=$true)]
    [ValidateSet("Standard_B4ms", "Standard_B1ms", "Standard_DS3_v2", "Standard_F4s_v2")]
    [string] $VMSize = "Standard_B4ms",
    
    [switch] $Linux,
    [switch] $DisableAADJoin
)

Import-Module bjd.common.functions

$vmName         = "bjd{0}" -f (New-Password -length 8 -ExcludedSpecialCharacters).ToLower()
$vmNic          = "{0}-nic" -f $vmName
$vmDisk         = "{0}-osdrive" -f $vmName

$adminUser      = "manager"
$keyVaultOpts   = @{
    "VaultName" = "bjdcorekeyvault"
    "Name"      = "managerPassword"
}

$timeZone       = "Central Standard Time"
$subnet         = "Servers"

$role           = "Virtual Machine Administrator Login"
$account        = "bjd@example.com"

$configMap = @{}
$configMap.Add("APP01_Subscription", (New-Object psobject -Property @{
    "ResourceGroupName"      = "DevSub01_Client_RG"
    "VnetResourceGroupName"  = "DevSub01_Network_RG"
    "VnetName"               = "DevSub01_VNet_001"
    "Location"               = "southcentralus"
}))
$configMap.Add("APP02_Subscription", (New-Object psobject -Property @{
    "ResourceGroupName"      = "DevSub02_Client_RG"
    "VnetResourceGroupName"  = "DevSub02_Network_RG"
    "VnetName"               = "DevSub02_VNet_002"
    "Location"               = "centralus"
}))
$configMap.Add("Core_Subscription", (New-Object psobject -Property @{
    "ResourceGroupName"      = "Core_Infra_Client_RG"
    "VnetResourceGroupName"  = "Core_Infra_Network_RG"
    "VnetName"               = "Core_VNet_001"
    "Location"               = "southcentralus"
}))
$config = $configMap[$SubscriptionName]

Select-AzSubscription -SubscriptionName $SubscriptionName
New-AzResourceGroup -Name $config.ResourceGroupName -Location $config.Location 

$vnet = Get-AzVirtualNetwork -Name $config.VnetName -ResourceGroupName $config.VnetResourceGroupName
$subnetId = Get-AzVirtualNetworkSubnetConfig -Name $subnet -VirtualNetwork $vnet | Select-Object -Expand id

$startTime = Get-Date

$vm = New-AzVMConfig -VMName $VMName -VMSize $VMSize -AssignIdentity
$nic = New-AzNetworkInterface -Name $vmNic -ResourceGroupName $config.ResourceGroupName -Location $config.Location -SubnetId $subnetId
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
$vm = Set-AzVMBootDiagnostic -VM $vm -Disable
$vm = Set-AzVMOSDisk -VM $vm -Name $vmDisk -CreateOption FromImage -StorageAccountType Premium_LRS 

if($linux) {
    $creds = New-PSCredentials -UserName $adminUser -Password ' '

    $publicKey = Get-PublicKey
    $vm = Set-AzVMOperatingSystem -VM $vm -Linux -ComputerName $vmName -Credential $creds -DisablePasswordAuthentication 
    $vm = Set-AzVMSourceImage -VM $vm -PublisherName Canonical -Offer UbuntuServer -Skus 18.04-LTS -Version latest

    $vm = Add-AzVMSshPublicKey -VM $vm -KeyData $publicKey -Path ("/home/{0}/.ssh/authorized_keys" -f $adminUser)
}
else {
    $keyVaultSecret = Get-AzKeyVaultSecret @keyVaultOpts
    $creds = New-PSCredentials -UserName $adminUser -Password $keyVaultSecret.SecretValueText

    $vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $creds -ProvisionVMAgent -EnableAutoUpdate -TimeZone $TimeZone    
    $vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' -Skus '19h2-pro' -Version latest
}
New-AzVM -ResourceGroupName $config.ResourceGroupName -Location $config.Location -VM $vm -Verbose

if(-not($linux) -and -not($DisableAADJoin)) {
    New-AzRoleAssignment -ResourceGroupName $config.ResourceGroupName -RoleDefinitionName $role -SignInName $account
    $extOps = @{
        Publisher           = "Microsoft.Azure.ActiveDirectory"
        Name                = "AADLoginForWindows"
        Type                = "AADLoginForWindows"
        TypeHandlerVersion  = "0.4"
        ResourceGroupName   = $config.ResourceGroupName
        Location            = $config.Location
        VMName              = $VMName
    }
    Set-AzVMExtension @extOps
}

$endTime = Get-Date

return (New-Object psobject -Property @{
    Name = $vmName 
    IPAddress =  $nic.IpConfigurations[0].PrivateIpAddress
    ElaspedSeconds = (New-TimeSpan -Start $startTime -End $endTime | Select-Object -ExpandProperty TotalSeconds)
})