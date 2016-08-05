param(
	[object] $WebHookData
)

if( $WebHookData -ne $null  )
{
	$app_id    = Get-AutomationVariable    -Name 'ApplicationId'
	$tenant_id = Get-AutomationVariable    -Name 'TenantId'
	$key       = Get-AutomationVariable    -Name 'WebHookKey' 
	$cert      = Get-AutomationCertificate -Name 'AuthCert'
	
	$WebhookBody = ConvertFrom-Json -InputObject $WebHookData.RequestBody
	
	if( $key -ne $WebhookBody.WebHookKey ) { throw "Invalid Key . . ."}
	if( !(Test-Path ("cert:\CurrentUser\My\{0}" -f $cert.Thumbprint) ) ) {
	    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser") 
	    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
	    $store.Add($cert) 
	    $store.Close() 	
	}		
	
	Login-AzureRmAccount -ServicePrincipal -TenantId $tenant_id -CertificateThumbprint $cert.Thumbprint -ApplicationId $app_id  
	
	$ResourceLocation           = "southcentralus"		
	$TemplateFileUri            = "https://bjdstorage.blob.core.windows.net/scripts/azuredeploy.json"
	$ResourceGroupName          = $WebhookBody.ResourceGroupName
	
	$params = @{
		VmNamePrefix             = $WebhookBody.VmNamePrefix
		localAdminUsername       = $WebhookBody.LocalAdminUsername
		localAdminPassword       = $WebhookBody.LocalAdminPassword
		domainAdminUsername      = $WebhookBody.DomainAdminUsername	
		domainAdminPassword      = $WebhookBody.DomainAdminPassword
		domainToJoin             = $WebhookBody.DomainToJoin
		storageAccountName       = $WebhookBody.StorageAccountName
		numberOfInstances        = $WebhookBody.NumberOfInstances
	}
	
	$opts = @{
	    Name                    = ("ResourceGroupDeployment-{0}" -f $(Get-Date).ToString("yyyyMMddhhmmss") )
	    ResourceGroupName       = $ResourceGroupName
	    TemplateUri             = $TemplateFileUri
	    TemplateParameterObject = $params
	}
	
	New-AzureRmResourcegroup -Name $ResourceGroupName -Location $ResourceLocation -Verbose
	New-AzureRmResourceGroupDeployment @opts
}