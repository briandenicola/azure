
Set-Variable -Name config -Value (Get-Content -Raw (Join-Path -Path $PSScriptRoot -ChildPath "bjd.Azure.Config.json") | ConvertFrom-Json)

function Get-AzAdminPassword {
    param(
        [switch] $CopytoClipboard
    )
    $secret = Get-AzKeyVaultSecret -VaultName $config.KeyVault.VaultName -Name $config.KeyVault.Name  | Select-object -Expand SecretValueText 
    
    if($CopytoClipboard) {
        Set-Clipboard -Value $secret
    } 
    else {
        return $secret
    }
  
}
function New-APIMHeader {
    param(
        [string] $key
    )
    $header = @{}
    $header.Add('Ocp-Apim-Subscription-Key', $Key)
    return $header
}

function Connect-ToAzureVPN {
    param ( 
        [Parameter(Mandatory=$false, HelpMessage='Enter a valid Destination Prefix in the format `"w.x.y.z/a`"')] 
        [ValidatePattern("^(?:[0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}$")]
        [string[]] $RemoteNetworkPrefixs = @("10.1.0.0/16","10.5.0.0/16","10.2.0.0/16"),
        [switch] $Disconnect
    )
    $VPNConnectionName = $config.VPNConnectionName

    $VPNPhonebook      = Join-Path -Path $ENV:APPDATA -ChildPath ("Microsoft\Network\Connections\Cm\{0}\{0}.pbk" -f $VPNConnectionName)

    if($Disconnect) {
        rasdial.exe $VPNConnectionName /disconnect
        return $true
    }

    $ip = Get-NetIPAddress -InterfaceAlias $VPNConnectionName  -ErrorAction SilentlyContinue

    if($null -eq $ip) {
        Write-Verbose -Message ("[{0}] - Establishing Connection Back to {1} . . ." -f (Get-Date), $VPNConnectionName )
        rasdial.exe $VPNConnectionName /phonebook:$VPNPhonebook
        $ip = Get-NetIPAddress -InterfaceAlias $VPNConnectionName | Select-Object -ExpandProperty IPAddress
        Get-NetRoute -InterfaceAlias $VPNConnectionName | Remove-NetRoute -Confirm:$false

        foreach( $prefix in $RemoteNetworkPrefixs ) {
            New-NetRoute -DestinationPrefix $prefix -NextHop $ip -InterfaceAlias $VPNConnectionName
        }

        Get-NetRoute -InterfaceAlias $VPNConnectionName
    }
}

function New-AzureVM {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("BJD_APP01_Subscription", "BJD_APP02_Subscription", "BJD_Core_Subscription")]
        [string] $SubscriptionName,
    
        [Parameter(Mandatory=$true)]
        [ValidateSet("Standard_B4ms", "Standard_B1ms", "Standard_DS3_v2", "Standard_F4s_v2")]
        [string] $VMSize,
        
        [Parameter(Mandatory=$false)]
        [string] $VnetResourceGroupName,
    
        [Parameter(Mandatory=$false)]
        [string] $VnetName,
    
        [switch] $Linux,
        [switch] $DisableAADJoin
    )
       
    $vmName     = "bjd{0}" -f (New-Uuid).Substring(0,8)
    $vmNic      = "{0}-nic" -f $vmName
    $vmDisk     = "{0}-osdrive" -f $vmName

    $adminUser  = $config.vmSettings.adminUser 
    $timeZone   = $config.vmSettings.timeZone                    
    $subnet     = $config.vmSettings.subnet
    $role       = $config.vmSettings.role
    $account    = $config.vmSettings.account

    if( -not([string]::IsNullOrEmpty($VnetResourceGroupName)) -and -not([string]::IsNullOrEmpty($VnetName)) ){
        $vmConfig.Add('ResourceGroupName',$VnetResourceGroupName)
        $vmConfig.Add('VnetResourceGroupName', $VnetResourceGroupName)
        $vmConfig.Add('VnetName', $VnetName)
        $vmConfig.Add('Location', (Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VnetResourceGroupName | Select-Object -ExpandProperty Location))
    }
    else {
        $vmConfig = $config.vmSettings.AzureSettings | Where-Object { $_.SubscriptionName -eq $SubscriptionName }
    }
    
    Select-AzSubscription -SubscriptionName $SubscriptionName
    New-AzResourceGroup -Name $vmConfig.ResourceGroupName -Location $vmConfig.Location 
    
    $vnet = Get-AzVirtualNetwork -Name $vmConfig.VnetName -ResourceGroupName $vmConfig.VnetResourceGroupName
    $subnetId = Get-AzVirtualNetworkSubnetConfig -Name $subnet -VirtualNetwork $vnet | Select-Object -Expand id
    
    $startTime = Get-Date
    
    $vm = New-AzVMConfig -VMName $VMName -VMSize $VMSize -AssignIdentity
    $nic = New-AzNetworkInterface -Name $vmNic -ResourceGroupName $vmConfig.ResourceGroupName -Location $vmConfig.Location -SubnetId $subnetId
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
        $keyVaultSecret = Get-AzAdminPassword
        $creds = New-PSCredentials -UserName $adminUser -Password $keyVaultSecret
    
        $vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $creds -ProvisionVMAgent -EnableAutoUpdate -TimeZone $TimeZone    
        $vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' -Skus '19h2-pro' -Version latest
    }
    New-AzVM -ResourceGroupName $vmConfig.ResourceGroupName -Location $vmConfig.Location -VM $vm -Verbose
    
    if(-not($linux) -and -not($DisableAADJoin)) {
        New-AzRoleAssignment -ResourceGroupName $vmConfig.ResourceGroupName -RoleDefinitionName $role -SignInName $account
        $extOps = @{
            Publisher           = "Microsoft.Azure.ActiveDirectory"
            Name                = "AADLoginForWindows"
            Type                = "AADLoginForWindows"
            TypeHandlerVersion  = "0.4"
            ResourceGroupName   = $vmConfig.ResourceGroupName
            Location            = $vmConfig.Location
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

}

function Get-AzCachedAccessToken {
    $currentAzureContext = Get-AzContext
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)
    return $token.AccessToken
}

function Invoke-AzRestMethod {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("GET","POST", "PUT")]
        [string] $Method,

        [Parameter(Mandatory=$true)]
        [string] $Uri,

        [Parameter(Mandatory=$false)]
        [string] $Body
    )

    $token = Get-AzCachedAccessToken
    $header = @{'Authorization' = ("Bearer {0}" -f $token)}

    if($Method -eq "GET") {
        $response = Invoke-RestMethod -Method $Method -Uri $Uri -ContentType "application/json" -Headers $header -Verbose
    }
    else {
        $response = Invoke-RestMethod -Method $Method -Uri $Uri -ContentType "application/json" -Body $Body -Headers $header -Verbose
    }
    return $response

}

Export-ModuleMember -Function Invoke-AzRestMethod, Get-AzCachedAccessToken, New-AzureVM, Get-AzAdminPassword, New-APIMHeader, Connect-ToAzureVPN 