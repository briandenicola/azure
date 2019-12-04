[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    $TagName
)

Import-Module Az.ResourceGraph

function Convert-ObjectToHash 
{
    param ( 
        [PSCustomObject] $CustomObject
    )
	
    $ht = @{}
    $Keys = $CustomObject | Get-Member -MemberType NoteProperty | Select-Object -Expand Name

    foreach ( $key in $Keys ) { 
        $ht.Add( $Key, $CustomObject.$key )
    }

    return $ht
}
	
Login-AzAccount

$subscriptions = Get-AzSubscription | Select-Object -ExpandProperty Id

$missingQuery = "project id, subscriptionId, tags | where isnull(tags.{0})" -f  $TagName
$countQuery = "summarize countif(isnull(tags.{0}))" -f $TagName

$total = Search-AzGraph -Query $countQuery -Subscription $subscriptions | Select-Object -ExpandProperty countif_
$batchSize = 50

Write-Verbose -Message ("Found {0} items" -f $total)
if( $total -eq 0 ) {
    Write-Output -InputObject "Zero objects found in query"
}

[System.Collections.ArrayList]$missing = @()
if( $total -le $batchSize ) {
    $missing += Search-AzGraph -Query $missingQuery -First $total -Subscription $subscriptions
}
else {
    $queryCount = 0
    while( $queryCount -lt $total)  {
        $missing += Search-AzGraph -Query $missingQuery -First $batchSize -Skip $queryCount -Subscription $subscriptions
        $queryCount += $batchSize
    }
}

foreach( $resource in $missing ) {
    Write-Verbose -Message ("Working on {0}" -f $resource.id)
    Select-AzSubscription -Subscription $resource.subscriptionId
    $caller =  Get-AzLog -ResourceId $resource.id | 
        Where-Object {$_.OperationName.Value -imatch "write"} | 
        Sort-Object EventTimestamp -Descending | 
        Select-Object -ExpandProperty Caller -First 1
    
    Write-Verbose -Message ("Found caller id {0}" -f $caller )
    $tags = $resource.tags
    $tags | Add-Member -MemberType NoteProperty -Name $TagName -Value $caller

    Set-AzResource -ResourceId $resource.id -Tags (Convert-ObjectToHash -CustomObject $tags) -Confirm:$false -Force 
}