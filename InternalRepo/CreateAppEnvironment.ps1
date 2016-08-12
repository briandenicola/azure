param(
	[string] $ResourceLocation = "southcentralus",
    [string] $SubscriptionName = "DevSub02",
	[string] $VNet_IP_Range = "10.4.0.0/16", 
	[string] $Mgmt_Subnet_Range = "10.4.200.0/24"
)

$app_id    = Get-AutomationVariable -Name 'ApplicationId'
$tenant_id = Get-AutomationVariable -Name 'TenantId' 
$cert      = Get-AutomationCertificate -Name 'AuthCert'

if( !(Test-Path ("cert:\CurrentUser\My\{0}" -f $cert.Thumbprint) ) ) {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser") 
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $store.Add($cert) 
    $store.Close() 	
}		
Login-AzureRmAccount -ServicePrincipal -TenantId $tenant_id -CertificateThumbprint $cert.Thumbprint -ApplicationId $app_id 

$CoreNetworkResourceGroup = "Core_Infra_Network_RG"
$core_vnet_name  = "BJD-Core-VNet-001"
$dns_server = "10.1.1.4"
$VNet_name  = "{0}-VNet-001" -f $SubscriptionName
$network_resource_group = "{0}_Network_RG" -f $SubscriptionName 

New-AzureRmResourcegroup -Name $network_resource_group -Location $ResourceLocation

$subnet_configs = @()
$core_vnet_subnets = @(
	@{ Name= 'Mgmt'; Range = $Mgmt_Subnet_Range }
)

foreach( $subnet in $core_vnet_subnets) {
	$subnet_configs += New-AzureRmVirtualNetworkSubnetConfig -Name $subnet.Name -AddressPrefix $subnet.Range
}

New-AzureRmVirtualNetwork -Name $VNet_name -ResourceGroupName $network_resource_group -Location $ResourceLocation -AddressPrefix $VNet_IP_Range -Subnet $subnet_configs
Set-AzureRMVnetDNSServer -ResourceGroupName $network_resource_group -VnetName $VNet_name -PrimaryDnsServerAddress $dns_server

$core_vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $CoreNetworkResourceGroup -Name $core_vnet_name
$depent_vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $network_resource_group -Name $VNet_name
Add-AzureRmVirtualNetworkPeering -name ("{0}-VNet" -f $VNet_name) -VirtualNetwork $core_vnet -RemoteVirtualNetworkId $depent_vnet.id -AllowForwardedTraffic -UseRemoteGateways 
Add-AzureRmVirtualNetworkPeering -name "Core-VNet" -VirtualNetwork $depent_vnet -RemoteVirtualNetworkId $core_vnet.id -AllowForwardedTraffic -UseRemoteGateways
