[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $subscriptionId,
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string] $RouteTableName,
    [Parameter(Mandatory=$true)]
    [string] $Region
)

Set-StrictMode -Version 5
function Get-AzureDataCenterIPRange {
    param(
        [string] $region
    )

    $downloadUri = "https://www.microsoft.com/en-in/download/confirmation.aspx?id=41653";
    $downloadPage = Invoke-WebRequest -Uri $downloadUri;
    $xmlFileUri = ($downloadPage.RawContent.Split('"') -like "https://*PublicIps*")[0];
    $response = Invoke-WebRequest -Uri $xmlFileUri;

    [xml]$xmlResponse = [System.Text.Encoding]::UTF8.GetString($response.Content);
    $regions = $xmlResponse.AzurePublicIpAddresses.Region;
    $ipRange = ( $regions | where-object Name -eq $region ).IpRange;

    return $ipRange
}

try { 
    Get-AzureRmResource 
}
catch { 
    Write-Verbose -Message ("[{0}] - Logging into Azure" -f $(Get-Date))
    Login-AzureRmAccount 
}
Select-AzureRmSubscription -SubscriptionId $subscriptionId

$subnets = Get-AzureDataCenterIPRange -region $region
$routeTable = Get-AzureRmRouteTable -ResourceGroupName $ResourceGroupName -Name $RouteTableName
if( $routeTable -eq $null ) {
    throw ("Could not find Route Table {0} in {1}" -f $RouteTableName, $ResourceGroupName)
}

foreach( $subnet in $subnets) {
    $routeTable | Add-AzureRmRouteConfig -AddressPrefix $subnet.Subnet -NextHopType Internet -Name ( "Route_{0}_to_Internet" -f $subnet.Subnet.Replace("/","-") ) -Verbose
}

Set-AzureRmRouteTable -RouteTable $routeTable -Verbose
