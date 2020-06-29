[CmdletBinding()]
param()

$servicePrincipalConnection = Get-AutomationConnection -Name "AzureRunAsConnection"        
Login-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

$StorageResourceGroupName = "Core_Infra_Storage_RG"
$ApplicationResourceGroupName = "DevSub01_App02_RG"
$PolicyContainer = "policies"
$StorageAccount = "bjdcoresa001"
$DestinationFolder = Join-Path -Path $ENV:TEMP -ChildPath ( "Policies-{0}" -f $(Get-Date).ToString("yyyyMMddhhmmss"))
$Subscription = Get-AzureRmContext | Select -Expand Subscription

if ( !(Test-Path -Path $DestinationFolder) ) {
    New-Item -Path $DestinationFolder -ItemType Directory
}

Set-AzureRmCurrentStorageAccount -ResourceGroupName $StorageResourceGroupName -StorageAccountName $StorageAccount
$blobs = Get-AzureStorageBlob -Container $PolicyContainer
$blobs | Get-AzureStorageBlobContent -Destination $DestinationFolder

$ResourceGroup = Get-AzureRmResourceGroup -Name $ApplicationResourceGroupName

$policies = Get-ChildItem -Path $DestinationFolder | Where Extension -eq ".json"
$defined_policies_names = Get-AzureRmPolicyDefinition | Select -ExpandProperty Name
$assigned_policies = Get-AzureRmPolicyAssignment -Scope $ResourceGroup.ResourceId  | Select -ExpandProperty Name
 
foreach ( $policy in $policies ) {

    if ( !$defined_policies_names.Contains($policy.BaseName) ) {
        Write-Verbose -Message ("{0} Policy Definition was not found on subscription {1}. Adding definition" -f $policy.BaseName, $Subscription.SubscriptionName )
        $policy_definition = New-AzureRmPolicyDefinition -Name $policy.BaseName -Policy $policy.FullName
    }
    else {
        $policy_definition = Get-AzureRmPolicyDefinition -Name $policy.BaseName
    } 


    if ( $assigned_policies -eq $null -or !$assigned_policies.Contains($policy.BaseName) ) {
        Write-Verbose -Message ("{0} Policy  was not assigned to {1} in subscription {2}. Assinging definition" -f $policy.BaseName, $ApplicationResourceGroupName, $Subscription.SubscriptionName )
        New-AzureRmPolicyAssignment -Name $policy.BaseName -PolicyDefinition $policy_definition -Scope $ResourceGroup.ResourceId
    }         
}

Remove-Item -Path $DestinationFolder -Recurse -Force -Confirm:$false