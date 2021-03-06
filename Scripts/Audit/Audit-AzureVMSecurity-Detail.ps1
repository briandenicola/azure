#$clientId = "ce7260a9-0828-4082-b4d6-1343a59f15ab"
#$clientSecret = "ENRWJwGrAsmEAEwSdlLpxnUzhPIdKA2/b8sfTNcqEBU="

param (
    [Parameter(Mandatory = $true)]
    [string] $ClientId,

    [Parameter(Mandatory = $true)]
    [string] $ClientSecret,

    [Parameter(Mandatory = $true)]
    [string] $subscriptionId,

    [Parameter(Mandatory = $true)]
    [string] $CSVPath
)

function Get-AzureVMMissingPatches {
    param (
        [string] $VM,
        [string] $ResourceGroup,
        [HashTable] $Headers
    )
    Set-Variable -Name API -Value "2015-06-01-preview" -Option Constant

    $uri = "https://{0}/subscriptions/{1}/resourceGroups/{2}/providers/microsoft.Compute/virtualMachines/{3}/providers/microsoft.Security/dataCollectionResults/patch?api-version={4}" 
    $patchUri = $uri -f "management.azure.com", $subscriptionId, $ResourceGroup, $VM, $API
    
    $request = Invoke-RestMethod -Method GET -Headers $headers -UseBasicParsing -Uri $patchUri
    $missingPatches = $request.properties.missingPatches | Select-Object @{N = "VMName"; E = { $VM } }, @{N = "ResourceGroup"; E = { $ResourceGroup } }, OsType, Title, Severity, Description 
    return $missingPatches
}

Set-StrictMode -Version 5
Import-Module -Name Azure_Functions -Force

try { 
    Set-AzureRmContext -SubscriptionId $subscriptionId | Out-Null
}
catch { 
    Write-Verbose -Message ("[{0}] - Logging into Azure" -f $(Get-Date))
    Login-AzureRmAccount 
    Set-AzureRmContext -SubscriptionId $subscriptionId | Out-Null
}

$tenant = Get-AzureRmContext | Select-Object -ExpandProperty Tenant | Select-Object -ExpandProperty Id
$body = @{"grant_type" = "client_credentials"; "resource" = "https://management.core.windows.net/"; "client_id" = $ClientID; "client_secret" = $ClientSecret }
$Token = Invoke-RestMethod -Uri https://login.microsoftonline.com/$tenant/oauth2/token?api-version=1.0 -Method Post -Body $body 

$headers = @{ }
$headers.Add( 'authorization' , ('bearer {0}' -f $token.access_token))   

$missingPatches = @()
foreach ( $vm in Get-AzureRMVM ) {
    $missingPatches += Get-AzureVMMissingPatches -VM $vm.Name -ResourceGroup $vm.ResourceGroupName -Header $headers
}

$missingPatches | Export-Csv -Encoding ASCII -NoTypeInformation -Path $CSVPath