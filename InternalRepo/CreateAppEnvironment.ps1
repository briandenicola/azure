param(
	[string] $ResourceLocation = "southcentralus"
    [string] $SubscriptionName,
	[string] $VNet_IP_Range
)

Import-Module Azure_functions

$app_id    = Get-AutomationVariable -Name 'ApplicationId'
$tenant_id = Get-AutomationVariable -Name 'TenantId' 
$cert      = Get-AutomationCertificate -Name 'AuthCert'

$CoreNetworkResourceGroup = "Core_Infra_Network_RG"
$core_vnet_name  = "BJD-Core-VNet-001"
$dns_server = "10.1.1.4"
	
if( !(Test-Path ("cert:\CurrentUser\My\{0}" -f $cert.Thumbprint) ) ) {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser") 
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $store.Add($cert) 
    $store.Close() 	
}		

Login-AzureRmAccount -ServicePrincipal -TenantId $tenant_id -CertificateThumbprint $cert.Thumbprint -ApplicationId $app_id 

$network_resource_group = "{0}_Network_RG" -f $SubscriptionName
New-AzureRmResourcegroup -Name $network_resource_group -Location $ResourceLocation -Verbose

$VNet_name  = "{0}-VNet-001" -f $SubscriptionName

$subnet_configs = @()
$core_vnet_subnets = @(
	@{ Name= 'Mgmt'; Range = "10.2.1.0/24" }
)

foreach( $subnet in $core_vnet_subnets) {
	$subnet_configs += New-AzureRmVirtualNetworkSubnetConfig -Name $subnet.Name -AddressPrefix $subnet.Range
}

New-AzureRmVirtualNetwork -Name $VNet_name -ResourceGroupName $network_resource_group -Location $ResourceLocation -AddressPrefix $VNet_IP_Range -Subnet $subnet_configs
Set-AzureRMVnetDNSServer -ResourceGroupName $network_resource_group -VnetName $VNet_name -PrimaryDnsServerAddress $dns_server