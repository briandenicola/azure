param (
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [string] $Tenant = "microsoft.onmicrosoft.com"
)

Import-Module AzureAD -MinimumVersion 2.0.0 -ErrorAction Stop

function Get-AuthToken
{
    param(
        [Parameter(Mandatory=$true)]
        $TenantName
    )

    $modulePath = Get-Module -Name AzureAD | Select-Object -ExpandProperty ModuleBase
    $adal = Join-Path -Path $modulePath -ChildPath "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

    if( !(Test-Path $adal) ) { throw "Could not find the required assembly - Microsoft.IdentityModel.Clients.ActiveDirectory.dll" }
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

    $clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://vault.azure.net"
    $authority = ("https://login.windows.net/{0}" -f $TenantName)
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId,$redirectUri, "Auto")

    return $authResult
}

$vault   = "https://bjdcorekeyvault.vault.azure.net/secrets/AzureAutomationKey/64318d6ee81d45fabda01a25626c3e2b?api-version=2016-10-01"
$webHook = "https://s5events.azure-automation.net/webhooks?token=prxWy5x7xVmk9L%2ft6pmgrKvzUTBvuxv2Cp5Dti75nK4%3d" 

try {
    $token = Get-AuthToken -TenantName $Tenant
    $headers = @{
        'Authorization' = $token.CreateAuthorizationHeader()
    }
    $key = Invoke-RestMethod -UseBasicParsing -Uri $vault -Headers $headers | Select-Object -ExpandProperty Value
    if( $key -eq $null ) { throw "Could not get key from vault" }

    $params = @{
        WebHookKey = $key
        ResourceGroupName = $ResourceGroupName
    }    
    Invoke-RestMethod -UseBasicParsing -Method Post -Uri $webHook -Body (ConvertTo-Json $params)
}
catch {}