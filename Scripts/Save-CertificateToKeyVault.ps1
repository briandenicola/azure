param(
    [string] $pfxFilePath,
    [string] $pfxPassword,
    [string] $KeyVaultName
)

$CertSecretName = "AzureWebAppCert"
$certPasswordName = "AzureWebAppCertPassword"

$pfxFileBytes = Get-Content $pfxFilePath -Encoding Byte
$pfxEncoded = [System.Convert]::ToBase64String($pfxFileBytes)
$secret = ConvertTo-SecureString -String $pfxEncoded -AsPlainText -Force
$secretContentType = 'application/x-pkcs12' 

Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $CertSecretName -SecretValue $secret -ContentType $secretContentType 

$secret = ConvertTo-SecureString -String $pfxPassword -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $certPasswordName -SecretValue $secret

$thumbprint = $collection | Where-Object HasPrivateKey -eq $true | Select-Object -First 1 -ExpandProperty Thumbprint
Write-Output ("Certificate Thumbprint = {0}" -f $thumbprint)