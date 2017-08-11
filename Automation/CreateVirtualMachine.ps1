param(
	[object] $WebHookData
)

if( $WebHookData -ne $null  )
{	
	$WebhookBody = ConvertFrom-Json -InputObject $WebHookData.RequestBody
	
	if( $key -ne $WebhookBody.WebHookKey ) { throw "Invalid Key . . ."}
    $servicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"        
    Login-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint   
	
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