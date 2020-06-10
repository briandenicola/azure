#Prereq   - 1. An existing VNet in Azure
#           2. Need a root and client certificate.  Can use a company's own PKI environment
#             If not using a company's PKI, then need to create a Root Certificate and a Child Certificate before creating the VPN.
#Note     - 1. Should update this to use New-SelfSignCertificate function
#           2. After VPN is setup, run Get-AzureRmVpnClientPackage -ResourceGroupName $RG -VirtualNetworkGatewayName $GWName -ProcessorArchitecture Amd64   
#Commands - 1. Make Root Cert   - makecert -sky exchange -r -n "CN=RootCertificateName" -pe -a sha1 -len 2048 -ss My "RootCertificateName.cer"
#           2. Make Client Cert - makecert.exe -n "CN=ClientCertificateName" -pe -sky exchange -m 96 -ss My -in "RootCertificateName" -is my -a sha1

$VNetName = "TestVNet"
$GWSubName = "GatewaySubnet"
$VPNClientAddressPool = "172.16.201.0/24"

$ResourceGroup = "TestRG"
$Location = "East US"

$GWName = "{0}-Gateway" -f $VNetName
$GWIPName = "Gateway-PIP"
$GWIPconfName = "Gateway-IpConfiguration"
$P2SRootCertName = "RootCertificateName.cer"

Login-AzureRmAccount

$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroup
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName -VirtualNetwork $vnet

$pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Dynamic
$ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip

$cert = Get-ChildItem -Path "cert:\localmachine\my" | where Subject -imatch "CN=RootCertificateName"
$MyP2SRootCertPubKeyBase64 = [convert]::ToBase64String($cert.Export("cer", [string]::Empty))
$p2srootcert = New-AzureRmVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $MyP2SRootCertPubKeyBase64

$gw = Get-AzureRmVirtualNetworkGateway -Name $GWIPName -ResourceGroupName $ResourceGroup 
if ($gw -eq $null) {
	$opts = @{
		Name                      = $GWName
		ResourceGroupName         = $ResourceGroup 
		Location                  = $Location
		IpConfigurations          = $ipconf
		GatewayType               = "Vpn" 
		VpnType                   = "RouteBased"
		EnableBgp                 = $false
		GatewaySku                = "Standard"
		VpnClientAddressPool      = $VPNClientAddressPool
		VpnClientRootCertificates = $p2srootcert
	}
	New-AzureRmVirtualNetworkGateway @opts
} 
else {
	$opts = @{
		VpnClientRootCertificateName = $P2SRootCertName 
		VirtualNetworkGatewayname    = $GWName 
		ResourceGroupName            = $ResourceGroup 
		PublicCertData               = $MyP2SRootCertPubKeyBase64
	}
	Add-AzureRmVpnClientRootCertificate @opts 
	Set-AzureRmVirtualNetworkGatewayVpnClientConfig -VirtualNetworkGateway $gw -VpnClientAddressPool $VPNClientAddressPool	
}
