$servicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"        
Login-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint  
Get-AzureRMVM | Start-AzureRMVM -verbose