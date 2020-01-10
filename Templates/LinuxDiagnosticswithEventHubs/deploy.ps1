param (
    # Deployment Information:
    [string]       $ResourceGroupName = "#",
    [string]       $ResourceLocation = "eastus2",
    
    # Event Hub Information:
    [string]       $EventHubNamespace = "#",
    [string]       $SyslogEventHubName = "syslog",
    [string]       $MetricsEventHubName = "metrics",
    
    # Event Hub Shared Access Policy Information:
    [string]       $SyslogAccessPolicyKey = "#",
    [string]       $MetricsAccessPolicyKey = "#",
    [string]       $SyslogAccessPolicyName = "#",
    [string]       $MetricsAccessPolicyName = "#",
    [int]          $Expiration = 30000 # Token expires now+30000
)

# Generate Syslog Event Hub SAS URL with Key and Name
[Reflection.Assembly]::LoadWithPartialName("System.Web")| out-null
$Syslog_URI= $EventHubNamespace + ".servicebus.windows.net/" + $SyslogEventHubName
$Syslog_Access_Policy_Name = $SyslogAccessPolicyName
$Syslog_Access_Policy_Key = $SyslogAccessPolicyKey
$SyslogExpires=([DateTimeOffset]::Now.ToUnixTimeSeconds())+$Expiration
$SyslogSignatureString=[System.Web.HttpUtility]::UrlEncode($Syslog_URI)+ "`n" + [string]$SyslogExpires
$SyslogHMAC = New-Object System.Security.Cryptography.HMACSHA256
$SyslogHMAC.key = [Text.Encoding]::ASCII.GetBytes($Syslog_Access_Policy_Key)
$SyslogSignature = $SyslogHMAC.ComputeHash([Text.Encoding]::ASCII.GetBytes($SyslogSignatureString))
$SyslogSignature = [Convert]::ToBase64String($SyslogSignature)
$SyslogSASToken = "sr=" + [System.Web.HttpUtility]::UrlEncode($Syslog_URI) + "&sig=" + [System.Web.HttpUtility]::UrlEncode($SyslogSignature) + "&se=" + $SyslogExpires + "&skn=" + $Syslog_Access_Policy_Name
$SyslogSasURL = "https://" + $Syslog_URI + '?' + $SyslogSASToken

# Generate Metrics Event Hub SAS URL with Key and Name
[Reflection.Assembly]::LoadWithPartialName("System.Web")| out-null
$Metrics_URI= $EventHubNamespace + ".servicebus.windows.net/" + $MetricsEventHubName
$Metrics_Access_Policy_Name = $MetricsAccessPolicyName
$Metrics_Access_Policy_Key = $MetricsAccessPolicyKey
$MetricsExpires=([DateTimeOffset]::Now.ToUnixTimeSeconds())+$Expiration
$MetricsSignatureString=[System.Web.HttpUtility]::UrlEncode($Metrics_URI)+ "`n" + [string]$MetricsExpires
$MetricsHMAC = New-Object System.Security.Cryptography.HMACSHA256
$MetricsHMAC.key = [Text.Encoding]::ASCII.GetBytes($Metrics_Access_Policy_Key)
$MetricsSignature = $MetricsHMAC.ComputeHash([Text.Encoding]::ASCII.GetBytes($MetricsSignatureString))
$MetricsSignature = [Convert]::ToBase64String($MetricsSignature)
$MetricsSASToken = "sr=" + [System.Web.HttpUtility]::UrlEncode($Metrics_URI) + "&sig=" + [System.Web.HttpUtility]::UrlEncode($MetricsSignature) + "&se=" + $MetricsExpires + "&skn=" + $Metrics_Access_Policy_Name
$MetricsSasURL = "https://" + $Metrics_URI + '?' + $MetricsSASToken

$opts = @{
    Name                  = ("Deployment-{0}-{1}" -f $ResourceGroupName, $(Get-Date).ToString("yyyyMMddhhmmss"))
    ResourceGroupName     = $ResourceGroupName
    TemplateFile          = (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.json")
    TemplateParameterFile = (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.parameters.json")
    adminPassword         = (Read-Host -Prompt "Enter the administrator password" -AsSecureString)
    syslogSASurl          = $SyslogSasURL
    metricsSASurl         = $MetricsSasURL
}

New-AzResourcegroup -Name $ResourceGroupName -Location $ResourceLocation -Verbose
New-AzResourceGroupDeployment @opts -Verbose