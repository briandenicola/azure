param(
    [string] $Url,
    [string] $key,
    [string] $Subject,
    [PSObject] $object
)

#$p = New-Object PSOBject -Property @{
#    firstName = "Joe"
#    lastName = "Smith"
#}
#$person = New-Object PSObject -Property @{
#    title = "Person"
#    properties = $p
#}

$eventTypeTemplate = @"
    [<
        "id": "{0}",
        "eventType": "recordInserted",
        "subject": "{1}",
        "eventTime": "{2}",
        "data": {3},
        "dataVersion": "1.0"
    >]
"@

$evnt = $eventTypeTemplate -f (New-Guid).Guid, $Subject, (Get-Date -Format s), ($object | ConvertTo-Json)
$evnt = ($evnt -replace ">", "}") -replace "<", "{"

$headers = @{}
$headers.Add('aeg-sas-key', $key)
Invoke-RestMethod -Method Post -UseBasicParsing -Uri $url -Headers $headers -Body $evnt -Verbose