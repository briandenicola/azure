#requires -version 3.0
[CmdletBinding()]
param( 
    [Parameter(Mandatory=$true)]
    [string]
    $UserName,

    [Parameter(Mandatory=$true)]
    [string]
    $Password,

    [Parameter(Mandatory=$true)]
    [string]
    $OrganizationName,

    [Parameter(Mandatory=$true)]
    [string]
    $ProjectName,

    [Parameter(Mandatory=$true)]
    [string]
    $ConnectionName,

    [Parameter(Mandatory=$true)]
    [string]
    [ValidateScript( {Test-Path $_})]
    $KubeConfigPath,

    [Parameter(Mandatory=$true)]
    [string]
    $KubeMasterUri,

    [Parameter(Mandatory=$true)]
    [string]
    $KubeContext
)

$uri = "https://dev.azure.com/{0}/{1}/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2" -f $OrganizationName, $ProjectName
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$headers =  @{}
$headers.Add("Authorization", "Basic {0}" -f $base64AuthInfo)

$config = [string]::join( "`n",(Get-Content -Path $KubeConfigPath -Encoding utf8))

$endpoint_type = New-Object psobject -Property @{
	authorizationType = "Kubeconfig"
    acceptUntrustedCerts = "true"
}

$auth = New-Object psobject -Property @{
    parameters = New-Object psobject -Property @{
      clusterContext = $KubeContext
      kubeconfig = $config
    }
    scheme = "Kubernetes"
}

$endpoint = New-Object psobject -Property @{
    data = $endpoint_type
    id = [System.Guid]::NewGuid().ToString()
    name =  $ConnectionName
    type = "kubernetes"
    url = $KubeMasterUri
    authorization = $auth
    isShared = "false"
    isReady = "true"
    owner = "Library"
}
Invoke-RestMethod -UseBasicParsing -Uri $uri -Method Post -Headers $headers -Body (ConvertTo-Json $endpoint) -ContentType "application/json"