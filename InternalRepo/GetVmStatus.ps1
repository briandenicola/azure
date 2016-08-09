$app_id    = Get-AutomationVariable -Name 'ApplicationId'
$tenant_id = Get-AutomationVariable -Name 'TenantId' 
$cert      = Get-AutomationCertificate -Name 'ClassicAuthCert'

if( !(Test-Path ("cert:\CurrentUser\My\{0}" -f $cert.Thumbprint) ) ) {
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser") 
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $store.Add($cert) 
    $store.Close() 	
}		

Login-AzureRmAccount -ServicePrincipal -TenantId $tenant_id -CertificateThumbprint $cert.Thumbprint -ApplicationId $app_id  

$vms = Get-AzureRmVm | Select Name,ResourceGroupName
$states = foreach( $vm in $vms ) {
   Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
}
$states | Select Name, @{N="State";E={$_.Statuses[1].Code}} 