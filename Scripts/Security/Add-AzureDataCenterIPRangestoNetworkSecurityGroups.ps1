[CmdletBinding()]
param(
    [string] $subscriptionId         = "2deb88fe-eca8-499a-adb9-6e0ea8b6c1d2",
    [string] $nsgResourceGroupName   = "NSGTest",
    [string] $nsgName                = "NSGRules",
    [string] $region                 = "ussouth"
)

Set-StrictMode -Version 5

Import-Module -Name Azure_Functions -Force
Import-Module -Name AzureRmStorageTable

$logResourceGroupName   = "NSGTest"
$logStorageAccountName  = "bjdnsgruleslog"
$logTableName           = "Logs"
$partitionKey           = "NSGRulesUpdate"

function Get-AzureDataCenterIPRange {
    param(
        [string] $region
    )

    $downloadUri = "https://www.microsoft.com/en-in/download/confirmation.aspx?id=41653";
    $downloadPage = Invoke-WebRequest -Uri $downloadUri;
    $xmlFileUri = ($downloadPage.RawContent.Split('"') -like "https://*PublicIps*")[0];
    $response = Invoke-WebRequest -Uri $xmlFileUri;

    [xml]$xmlResponse = [System.Text.Encoding]::UTF8.GetString($response.Content);
    $regions = $xmlResponse.AzurePublicIpAddresses.Region;
    $ipRange = ( $regions | where-object Name -eq $region ).IpRange;

    return $ipRange
}

function Write-Log {
    param (
        [string] $RuleName,
        [string] $SubnetRange,
        [string] $Result
    )

    $properties = @{
        RuleName    = $RuleName
        SubnetRange = $SubnetRange
        Result      = $Result
        TimeStamp   = (Get-Date)    
    }

    $saContext = (Get-AzureRmStorageAccount -ResourceGroupName $logResourceGroupName -Name $logStorageAccountName).Context
    $table = Get-AzureStorageTable -Name $logTableName -Context $saContext
    Add-StorageTableRow -table $table -partitionKey $partitionKey -rowKey ([guid]::NewGuid().tostring()) -property $properties
}

try { 
    Get-AzureRmResource 
}
catch { 
    Write-Verbose -Message ("[{0}] - Logging into Azure" -f $(Get-Date))
    Login-AzureRmAccount 
}
Select-AzureRmSubscription -SubscriptionId $subscriptionId

$subnets = Get-AzureDataCenterIPRange -region $region
$nsgRules = Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $nsgResourceGroupName

if( $nsgRules.SecurityRules.Count -eq 0 ) { 
    $rulePriority = 100
}
else {
    $rulePriority = ($nsgRules.SecurityRules | Sort-Object Priority -Descending | Select-Object -First 1 -ExpandProperty Priority) + 1
}

foreach ($subnet in $subnets.Subnet ) {
    $ruleName = "Allow_Azure_Out_" + $subnet.Split("/")[0]

    if( $ruleName -notin ($nsgRules.SecurityRules | Select-Object -ExpandProperty Name) ) {
        try{
            $opts = @{
                Name                        = $ruleName
                Description                 = ("Allow outbound to Azure - {0}") -f $subnet
                Access                      = "Allow"
                Protocol                    = "*"
                Direction                   = "Outbound"
                Priority                    = $rulePriority 
                SourceAddressPrefix         = "VirtualNetwork"
                SourcePortRange             = "*"
                DestinationAddressPrefix    = $subnet
                DestinationPortRange        = "*"
            }

            Write-Verbose -Message ("Adding Rule {0} to {1} in {2}" -f $ruleName, $nsgName, $nsgResourceGroupName)
            Get-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $nsgResourceGroupName |
                Add-AzureRmNetworkSecurityRuleConfig @opts |
                Set-AzureRmNetworkSecurityGroup |
                Out-Null

            $rulePriority++

            Write-Verbose -Message ("Logging Success for Rule {0} to {1} " -f $ruleName, $logTableName)
            Write-Log -RuleName $ruleName -SubnetRange $subnet -Result "[Success]"
        }
        catch {
            Write-Verbose -Message ("Logging Failure for Rule {0} to {1} " -f $ruleName, $logTableName)
            Write-Log -RuleName $ruleName -SubnetRange $subnet -Result "[Failed]"
        }
    }
}
