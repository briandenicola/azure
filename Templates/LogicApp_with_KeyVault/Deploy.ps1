param (
	[Parameter(Mandatory=$true)]
    [string]       $ResourceGroupName,
    [string]       $ResourceLocation           = "southcentralus"
)  
$opts = @{
    Name                  = ("Deployment-{0}-{1}" -f $ResourceGroupName, $(Get-Date).ToString("yyyyMMddhhmmss"))
    ResourceGroupName     = $ResourceGroupName
    TemplateFile          = (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.json")
    TemplateParameterFile = (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.parameters.json")
}

$account =  Get-AzContext | Select-Object -ExpandProperty Account 
$id = Get-AzADUser -UserPrincipalName $account.id | Select-Object -ExpandProperty Id 

New-AzResourcegroup -Name $ResourceGroupName -Location $ResourceLocation -Verbose
New-AzResourceGroupDeployment @opts -KeyVaultOwnerId $id -verbose   