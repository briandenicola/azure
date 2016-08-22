$cred = Get-AutomationPSCredential -Name "AutomationCredential"
Add-AzureRmAccount -Credential $cred

$rgs = @("BJDRG")
foreach( $group in $rgs) {
    Get-AzureRMVM -ResourceGroupName $group | Stop-AzureRMVM
}