$cred = Get-AutomationPSCredential -Name "AutomationCredential"

$rgs = @("BJDRG")
Add-AzureRmAccount -Credential $cred

foreach( $group in $rgs) {
    Get-AzureRMVM -ResourceGroupName $group | Start-AzureRMVM
}