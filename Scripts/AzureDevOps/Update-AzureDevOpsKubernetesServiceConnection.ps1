#requires -version 3.0
[CmdletBinding()]
param( 
    [Parameter(Mandatory = $true)]
    [string]
    $UserName,

    [Parameter(Mandatory = $true)]
    [string]
    $Password,

    [Parameter(Mandatory = $true)]
    [string]
    $OrganizationName,

    [Parameter(Mandatory = $true)]
    [string]
    $ProjectName,

    [Parameter(Mandatory = $true)]
    [string]
    $ConnectionName,

    [Parameter(Mandatory = $true)]
    [string]
    [ValidateScript( { Test-Path $_ })]
    $KubeConfigPath
)

$getUri = "https://dev.azure.com/{0}/{1}/_apis/serviceendpoint/endpoints/?endpointNames={2}&api-version=5.0-preview.2" -f $OrganizationName, $ProjectName, $ConnectionName

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

$headers = @{ }
$headers.Add("Authorization", "Basic {0}" -f $base64AuthInfo)

$config = [string]::join( "`n", (Get-Content -Path $KubeConfigPath -Encoding utf8))

$endpoint = Invoke-RestMethod -UseBasicParsing -Uri $geturi -Method Get -Headers $headers -ContentType "application/json"
if ( $endpoint.count -eq 0 ) {
    Write-Error -Message ("No endpoint with the name {0} was found. " -f $ConnectionName)
    exit
}
if ( $endpoint.count -gt 1 ) {
    Write-Error -Message ("Multiple endpoints with the name 0} was found. Script can not update multiples at this time." -f $ConnectionName)
    exit
}
$updatedEndpoint = $endpoint.value | Select-Object -First 1

$auth = New-Object psobject -Property @{
    parameters = New-Object psobject -Property @{
        clusterContext = $updatedEndpoint.authorization.parameters.clusterContext
        kubeconfig     = $config
    }
    scheme     = "Kubernetes"
}
$updatedEndpoint.authorization = $auth
$updateUri = "https://dev.azure.com/{0}/{1}/_apis/serviceendpoint/endpoints/{2}?api-version=5.0-preview.2" -f $OrganizationName, $ProjectName, $updatedEndpoint.id

Invoke-RestMethod -UseBasicParsing -Uri $updateUri -Method Put -Headers $headers -Body (ConvertTo-Json $updatedEndpoint) -ContentType "application/json"