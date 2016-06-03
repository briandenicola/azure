$cred = Get-AutomationPSCredential -Name "AutomationCredential"
	
Add-AzureRmAccount -Credential $cred
Get-AzureRMVM -ResourceGroupName BJDRG -Name vm1 | Start-AzureRMVM