Set-Variable -Name config -Value (Get-Content -Raw (Join-Path -Path $PSScriptRoot -ChildPath "bjd.Azure.Config.json") | ConvertFrom-Json)

function Get-KubernetesSecret
{
    param(
        [string] $secret,
        [string] $key
    )

    $encoded_key = kubectl get secret $secret -o json | ConvertFrom-Json
    return ConvertFrom-Base64EncodedString($encoded_key.data.$key)
}

function Copy-PathtoStorage
{
    param(
        [string] $StorageAccount,
        [string] $Container = "`$web",
        [string] $LocalPath
    )

    function Add-Quotes {
        begin {
            $quotedText = [string]::empty
        }
        process {
            $quotedText = "`"{0}`"" -f $_
        }
        end {
            return $quotedText
        }
    }

    $source = ("{0}/*" -f $LocalPath) | Add-Quotes 
    az storage copy --source $source --account-name $StorageAccount --destination-container $Container --recursive --put-md5
}

function Add-IPtoAksAllowedRange 
{
    param(
        [string] $IP,
        [string] $AKSCluster,
        [string] $ResourceGroup
    )

    $range = @(az aks show -n $AKSCluster -g $ResourceGroup --query apiServerAccessProfile.authorizedIpRanges -o tsv)
    $range += $IP
    
    return ([string]::Join(',', $range))
}

function Convert-CertificatetoBase64 {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_})]
        [string] $CertPath,

        [switch] $CopytoClipboard
        
    )
    $base64Cert = [convert]::ToBase64String( (Get-Content -AsByteStream -Path $CertPath) )

    if($CopytoClipboard) {
        Set-Clipboard -Value $base64Cert
    } 
    
    return $base64Cert
}

function Get-AzAdminPassword {
    Get-KeyVaultSecret -KeyVaultName $config.keyVault.VaultName -SecretName $config.keyVault.secrets.admin -CopytoClipboard
}

function Get-AzDevOpsToken {
    Get-KeyVaultSecret -KeyVaultName $config.keyVault.VaultName -SecretName $config.keyVault.secrets.Token -CopytoClipboard
}

function Get-AzServicePrincipalSecret {
    Get-KeyVaultSecret -KeyVaultName $config.keyVault.VaultName -SecretName $config.keyVault.secrets.Secret -CopytoClipboard
}

function Get-KeyVaultSecret {
    param(
        [string] $KeyVaultName,
        [string] $SecretName,
        [switch] $CopytoClipboard
    )

    Set-EnvironmentVariable -Key SuppressAzurePowerShellBreakingChangeWarnings -Value $true 

    $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName | Select-Object -Property SecretValue
    $plainTextSecret = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
    
    if($CopytoClipboard) {
        Set-Clipboard -Value $plainTextSecret
    } 
    
    Set-EnvironmentVariable -Key SuppressAzurePowerShellBreakingChangeWarnings -Value $false 

    return $plainTextSecret  
}

function New-APIMHeader {
    param(
        [string] $key
    )
    $header = @{}
    $header.Add('Ocp-Apim-Subscription-Key', $Key)
    return $header
}

function Get-AzVPNStatus {
    [CmdletBinding()]
    param()

    $VPNConnectionName = $config.VPNConnectionName 
    Write-Verbose -Message ("[{0}] - Checking Connection status - {1} . . ." -f (Get-Date), $VPNConnectionName)
    Get-NetIPAddress -InterfaceAlias $VPNConnectionName  -ErrorAction SilentlyContinue 
    return $?
}

function Connect-ToAzureVPN {
    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory=$false, HelpMessage='Enter a valid Destination Prefix in the format `"w.x.y.z/a`"')] 
        [ValidatePattern("^(?:[0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}$")]
        [string[]] $RemoteNetworkPrefixs = @("10.1.0.0/16","10.2.0.0/16", "10.5.0.0/16", "10.25.0.0/16"),
        [switch] $Disconnect
    )
    $VPNConnectionName = $config.VPNConnectionName

    $VPNPhonebook      = Join-Path -Path $ENV:APPDATA -ChildPath ("Microsoft\Network\Connections\Cm\{0}\{0}.pbk" -f $VPNConnectionName)

    if($Disconnect) {
        rasdial.exe $VPNConnectionName /disconnect
        return $true
    }
  
    if(-not(Get-AzVPNStatus)) {
        Write-Verbose -Message ("[{0}] - Establishing Connection Back to {1} . . ." -f (Get-Date), $VPNConnectionName )
        rasdial.exe $VPNConnectionName /phonebook:$VPNPhonebook
        $ip = Get-NetIPAddress -InterfaceAlias $VPNConnectionName | Select-Object -ExpandProperty IPAddress
        Get-NetRoute -InterfaceAlias $VPNConnectionName | Remove-NetRoute -Confirm:$false

        foreach( $prefix in $RemoteNetworkPrefixs ) {
            New-NetRoute -DestinationPrefix $prefix -NextHop $ip -InterfaceAlias $VPNConnectionName
        }

        Get-NetRoute -InterfaceAlias $VPNConnectionName
    }
    else {
        Write-Verbose -Message ("[{0}] - Already connected to {1} . . ." -f (Get-Date), $VPNConnectionName ) 
    }
}

function New-AzureVM {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("BJD_APPS_Subscription", "BJD_AKS_Subscription", "BJD_Core_Subscription")]
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
    
    Select-AzSubscription -SubscriptionName $SubscriptionName

    $vmName     = "bjd{0}" -f (New-Uuid).Substring(0,8)
    $vmNic      = "{0}-nic" -f $vmName
    $vmDisk     = "{0}-osdrive" -f $vmName

    $adminUser  = $config.vmSettings.adminUser 
    $timeZone   = $config.vmSettings.timeZone                    
    $subnet     = $config.vmSettings.subnet
    $role       = $config.vmSettings.role
    $account    = $config.vmSettings.account

    $vmConfig = @{}
    if( -not([string]::IsNullOrEmpty($VnetResourceGroupName)) -and -not([string]::IsNullOrEmpty($VnetName)) ){
        $vmConfig.Add('ResourceGroupName',$VnetResourceGroupName)
        $vmConfig.Add('VnetResourceGroupName', $VnetResourceGroupName)
        $vmConfig.Add('VnetName', $VnetName)
        $vmConfig.Add('Location', (Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VnetResourceGroupName | Select-Object -ExpandProperty Location))
    }
    else {
        $vmConfig = $config.vmSettings.AzureSettings | Where-Object { $_.SubscriptionName -eq $SubscriptionName }
    }
    
    New-AzResourceGroup -Name $vmConfig.ResourceGroupName -Location $vmConfig.Location 
    
    $vnet = Get-AzVirtualNetwork -Name $vmConfig.VnetName -ResourceGroupName $vmConfig.VnetResourceGroupName
    $subnetId = Get-AzVirtualNetworkSubnetConfig -Name $subnet -VirtualNetwork $vnet | Select-Object -Expand id
    
    $startTime = Get-Date
    
    $vm = New-AzVMConfig -VMName $VMName -VMSize $VMSize -IdentityType SystemAssigned
    $nic = New-AzNetworkInterface -Name $vmNic -ResourceGroupName $vmConfig.ResourceGroupName -Location $vmConfig.Location -SubnetId $subnetId
    $vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
    $vm = Set-AzVMBootDiagnostic -VM $vm -Disable
    $vm = Set-AzVMOSDisk -VM $vm -Name $vmDisk -CreateOption FromImage -StorageAccountType Premium_LRS 

    if($linux) {
        $creds = New-PSCredentials -UserName $adminUser -Password ' '
    
        $publicKey = Get-PublicKey
        $vm = Set-AzVMOperatingSystem -VM $vm -Linux -ComputerName $vmName -Credential $creds -DisablePasswordAuthentication 
        $vm = Set-AzVMSourceImage -VM $vm -PublisherName Canonical -Offer 0001-com-ubuntu-server-focal -Skus 20_04-lts -Version latest
    
        $vm = Add-AzVMSshPublicKey -VM $vm -KeyData $publicKey -Path ("/home/{0}/.ssh/authorized_keys" -f $adminUser)
    }
    else {
        $keyVaultSecret = Get-AzAdminPassword
        $creds = New-PSCredentials -UserName $adminUser -Password $keyVaultSecret
    
        $vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $creds -ProvisionVMAgent -EnableAutoUpdate -TimeZone $TimeZone    
        $vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsDesktop' -Offer 'Windows-10' -Skus '20h1-pro' -Version latest
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

function Invoke-CustomAzRestMethod {
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

function Split-AzResourceID {
    param (
        [Parameter(Mandatory=$true)]
        [string] $ResourceID
    )

    $MatchString = "/subscriptions/(.*)/resourcegroups/(.*)/providers/(.*)/(.*)"

    if( $ResourceID.ToLower() -match $MatchString ) {
        return [ordered]@{
            SubscriptionID      = $Matches[1]
            ResourceGroupName   = $Matches[2]
            ResourceType        = $Matches[3]
            ResourceName        = $Matches[4]
        }
    }
    else {
        throw "Could not parse Resource ID.  Is it a valid Azure Resource ID?"
    }
}

function Get-AzWebAppFileSystemQuotaUsed {
    param(
        [Parameter(
            Mandatory = $true)]
        [String] $SubscriptionName,

        [Parameter(
            ParameterSetName = "All",
            Mandatory = $true)]
        [Switch] $All,


        [Parameter(
            ParameterSetName = "Specfic",
            Mandatory = $true)]
        [String] $ResourceGroupName,

        [Parameter(
            ParameterSetName = "Specfic",
            Mandatory = $true)]
        [String] $AppServicePlanName
    )
    
    function Format-Quota {
        param(
            [Parameter(
                Mandatory = $true,
                ValueFromPipeline = $true)
            ]
            [Object[]] $Value
        )

        return [math]::Round(
            ($Value | Select-Object -ExpandProperty CurrentValue)/1mb, 2
        )
    }

    Select-AzSubscription -SubscriptionName $SubscriptionName | Out-Null

    $uri = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/serverfarms/{2}/usages?api-version=2020-12-01"

    switch ($PsCmdlet.ParameterSetName) { 
        "Specfic" { 
            $sites = @(Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName)
        }
        "All" {
            $sites = @(Get-AzAppServicePlan)
        }
    }

    $usageTotals = @()
    foreach( $site in $sites ) {
        $fqdnUri = $uri -f $site.Subscription, $site.ResourceGroup, $site.Name

        $usage = Invoke-AzRestMethod -Uri $fqdnUri | Select-Object -ExpandProperty Content | ConvertFrom-Json
        
        $usageTotals += (New-Object psobject -Property @{
            AppServicePlan  = $site.Name
            ResourceGroup   = $site.ResourceGroup
            QuotaUsed       = $usage.Value | Where-Object { $_.name.value -eq "FileSystemStorage" } | Format-Quota
        })
    }

    return $usageTotals
}

$FuncsToExport = @(
    "Add-IPtoAksAllowedRange",
    "Copy-PathtoStorage",
    "Get-KubernetesSecret",
    "Invoke-CustomAzRestMethod",
    "Get-AzCachedAccessToken", 
    "New-AzureVM",
    "Get-AzAdminPassword",
    "Get-AzDevOpsToken",
    "Get-AzServicePrincipalSecret",
    "New-APIMHeader", 
    "Connect-ToAzureVPN", 
    "Convert-CertificatetoBase64",
    "Get-AzVPNStatus",
    "Split-AzResourceID",
    "Get-AzWebAppFileSystemQuotaUsed"
)
Export-ModuleMember -Function  $FuncsToExport