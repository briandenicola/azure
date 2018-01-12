[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string] $RouteTableName
)

Set-StrictMode -Version 5

function Get-AzureASEMgmtIpAddressesForRegion {
    param(
        [string] $region
    )

    $management_page = "https://docs.microsoft.com/en-us/azure/app-service/environment/management-addresses"
    $content = (Invoke-WebRequest -UseBasicParsing -Uri $management_page).Content
    $ips = $content.Split("`n") | Where-Object { $_ -imatch '<td>' }
    $results = $ips | Select-String -Context 1 -SimpleMatch $region 
    return ( $results.Context.PostContext.TrimStart('<td>').TrimEnd('</td>').Split(',').TrimStart() )
}

try { 
    Get-AzureRmResource 
}
catch { 
    Write-Verbose -Message ("[{0}] - Logging into Azure" -f $(Get-Date))
    Login-AzureRmAccount 
}

$routeTable = Get-AzureRmRouteTable -ResourceGroupName $ResourceGroupName -Name $RouteTableName
if( $routeTable -eq $null ) {
    throw ("Could not find Route Table {0} in {1}" -f $RouteTableName, $ResourceGroupName)
}

$location = Get-AzureRmLocation | Where-Object Location -eq $routeTable.Location | Select-Object -ExpandProperty DisplayName
$mgmtIpAddresses = Get-AzureASEMgmtIpAddressesForRegion -region $location

foreach( $ipAddress in $mgmtIpAddresses) {
    $routeTable | Add-AzureRmRouteConfig -AddressPrefix ("{0}/32" -f $ipAddress) -NextHopType Internet -Name ( "Azure-Management-{0}-Route" -f $ipAddress) -Verbose
}

Set-AzureRmRouteTable -RouteTable $routeTable -Verbose