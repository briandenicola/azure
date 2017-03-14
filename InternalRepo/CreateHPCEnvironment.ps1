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
	$TemplateFileUri            = "https://bjdstorage.blob.core.windows.net/scripts/azuredeploy.hpc.json"
	$ResourceGroupName          = $WebhookBody.ResourceGroupName
	
	$params = @{
		clusterName             = $WebhookBody.clusterName
		computerNodeNumber      = $WebhookBody.computerNodeNumber
		adminUsername       	= $WebhookBody.adminUsername
		adminPassword      		= $WebhookBody.adminPassword	
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