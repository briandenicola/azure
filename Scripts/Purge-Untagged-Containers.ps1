param (
    [Parameter(Mandatory=$true)]
    [String] $ACRName,
    
    [Parameter(Mandatory=$true)]
    [String] $RegistryName
)

$UntaggedContainers = $(az acr manifest list-metadata --name $RegistryName --registry $ACRName --query "[?tags[0]==null].digest" --output tsv)

foreach( $UntaggedContainer in $UntaggedContainers ) {
    Write-Host -Message ("[{0}] - Purging {1}.azurecr.io:{2}@{3}" -f (Get-Date), $ACRName, $RegistryName, $UntaggedContainer)
    az acr repository delete --name $ACRName --image $RegistryName@$UntaggedContainer --yes
}