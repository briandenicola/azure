param (
    [Parameter(Mandatory=$true)]
    [string] $Organization,

    [Parameter(Mandatory=$true)]
    [string] $Project,

    [Parameter(Mandatory=$true)]
    [string] $UserName
)

function Write-Response {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [psobject] $Output
    ) 

    process {
        $display = @(
            @{N="Release Name";E={$_.releaseDefinition.name}},  
            @{N="Release Stage";E={$_.releaseEnvironment.name}},
            @{N="Status";E={$_.status}},
            @{N="TimeStamp";E={$_.modifiedOn}},  
            @{N="Approver";E={$_.approvedBy.displayName}}
        )
        $Output | Select-Object -Property $display | Format-List
    }
}
function Set-Approval {
    param(
        [psobject] $pending,
        [pscredential] $auth
    )

    $approvalRequest = New-Object psobject -Property @{
        status = "Approved"
        approvedBy = $pending.approver.url
    }

    $opts = @{
        Authentication = "Basic"
        Credential = $auth
        UseBasicParsing = $true
        Uri = ("{0}?api-version=5.1" -f $pending.url)
        Method = "Patch"
        Body = (ConvertTo-Json $approvalRequest)
        ContentType = "application/json"
    }
    $response = Invoke-RestMethod @opts

    return $response
}

$auth = Get-Credential -UserName $UserName -Message ("Please enter the Personal Access Token (PAT) for {0}" -f $UserName)

$pendingApprovalOpts = @{
    Authentication = "Basic"
    Credential = $auth 
    UseBasicParsing = $true
    Uri = ("https://vsrm.dev.azure.com/{0}/{1}/_apis/release/approvals?api-version=5.1" -f $Organization, $Project)
}
$pending = Invoke-RestMethod @pendingApprovalOpts

if( $pending.Count -eq 1 ) {
    Set-Approval -pending $pending.value -auth $auth | Write-Response
}
elseif( $pending.Count -gt 1) {
    foreach( $pendingApproval in $pending.Value ) {
        Set-Approval -pending $pendingApproval -auth $auth | Write-Response
    }
}
else {
    Write-Host ("[{0}] - No pending release approvals for {1}/{2}" -f $(Get-Date), $Organization, $Project)
}

