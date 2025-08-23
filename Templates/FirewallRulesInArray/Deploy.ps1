param (
	[Parameter(Mandatory=$true)]
    [string]       $ResourceGroupName          = "Template-Demo",
    [Parameter(Mandatory=$true)]
    [string]       $TemplateFileName,
    [string]       $ResourceLocation           = "southcentralus"
     
) 

$rule = @"                                                          
    {{                                                                    
        "type": "firewallrules",                                            
        "apiVersion": "2014-04-01",                                         
        "location": "[resourceGroup().location]",                           
        "name": "TestFirewallRules-{0}",                                    
        "dependsOn": [                                                      
            "[concat('Microsoft.Sql/servers/', parameters('sqlserverName'))]" 
        ],                                                                  
        "properties": {{                                                    
            "startIpAddress": "{1}",                                          
            "endIpAddress": "{2}"                                             
        }}                                                                  
    }}                                                                     
"@                                                                              
$params    = Get-Content -Path (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.parameters.json") | ConvertFrom-Json
$template  = Get-Content -Path $TemplateFileName

$rules = @()
foreach( $fwrule in $params.parameters.sqlServerFirewallRules.Value ) {
    $rules += $rule -f $fwrule.serverFirewallRuleName, $fwrule.serverFirewallStartIp, $fwrule.serverFirewallEndIp 
}

$template -replace "~~~FirewallRules~~~", [string]::join(",", $rules) | Out-File -FilePath (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.json")

$opts = @{
    Name                  = ("Deployment-{0}-{1}" -f $ResourceGroupName, $(Get-Date).ToString("yyyyMMddhhmmss"))
    ResourceGroupName     = $ResourceGroupName
    TemplateFile          = (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.json")
    TemplateParameterFile = (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.parameters.json")
}

New-AzureRmResourcegroup -Name $ResourceGroupName -Location $ResourceLocation -Verbose
New-AzureRmResourceGroupDeployment @opts -verbose   