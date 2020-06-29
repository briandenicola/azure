$servicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"        
Login-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint   

$vms = Get-AzureRmVm | Select Name, ResourceGroupName
$states = foreach ( $vm in $vms ) {
   Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status
}
$states | Select Name, @{N = "State"; E = { $_.Statuses[1].Code } }