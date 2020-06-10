param(
    [Parameter(Mandatory = $true)]
    [string] $StorageName,
    
    [Parameter(Mandatory = $true)]
    [string] $Storagekey,

    [Parameter(Mandatory = $true)]
    [string] $Container,


    [Parameter(Mandatory = $true)]
    [string] $FilePath
)

$ctx = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Storagekey
$Metadata = @{
    "Hash" = (Get-FileHash -Algorithm SHA256 -Path $FilePath).Hash
}
Set-AzureStorageBlobContent -File $FilePath -Container $Container -Metadata $Metadata -Context $ctx

$blob = Get-AzureStorageBlob -Context $ctx -Container $Container -Blob $FilePath
$blob.ICloudBlob.Metadata