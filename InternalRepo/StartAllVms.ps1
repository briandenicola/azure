$app_id    = Get-AutomationVariable -Name 'ApplicationId'
$tenant_id = Get-AutomationVariable -Name 'TenantId' 
$cert      = Get-AutomationCertificate -Name 'C;assicAuthCert'

if( !(Test-Path ("cert:\CurrentUser\My\{0}" -f $cert.Thumbprint) ) ) {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser") 
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $store.Add($cert) 
    $store.Close() 	
}		
  
Login-AzureRmAccount -ServicePrincipal -TenantId $tenant_id -CertificateThumbprint $cert.Thumbprint -ApplicationId $app_id  
Get-AzureRMVM | Start-AzureRMVM -verbose  