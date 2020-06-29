param(
	[object] $WebHookData
)
$key = Get-AutomationVariable -Name 'WebHookKey'

if ( $WebHookData -ne $null  ) {	
	$WebhookBody = ConvertFrom-Json -InputObject $WebHookData.RequestBody	
	if ( $key -ne $WebhookBody.WebHookKey ) { throw "Invalid Key . . ." }
	Write-Output ("Received the ResourceGroupName - {0} - from webhook" -f $WebhookBody.ResourceGroupName)
}