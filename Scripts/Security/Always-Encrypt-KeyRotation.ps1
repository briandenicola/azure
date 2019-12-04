param(
    [string] $User,
    [string] $password,
    [string] $server
)
Import-Module "SqlServer"

Login-AzureRmAccount

$databaseName = "AdventureWorks"
$connStr = 'Server=tcp:{0},1433;Initial Catalog=AdventureWorks;Persist Security Info=False;User ID={1};Password={2};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
$connection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection
$connection.ConnectionString = ($connStr -f $server, $user, $password)
$connection.Connect()
$server = New-Object Microsoft.SqlServer.Management.Smo.Server($connection)
$database = $server.Databases[$databaseName]

$service_principal = Get-AzureRmADServicePrincipal -SearchString "Brian Denicola"

$key_vault = "alwaysencrypt"
$old_Column_Master_Key = "CMKAuto2"
$new_Column_Master_Key  = "CMKPowerShell2"

Set-AzureRmKeyVaultAccessPolicy -VaultName $key_vault -PermissionsToKeys get, create, delete, list, update, import, backup, restore, wrapKey, unwrapKey, sign, verify -UserPrincipalName $service_principal.Account

$column_master_settings = New-SqlAzureKeyVaultColumnMasterKeySettings -KeyUrl ("https://{0}.vault.azure.net/keys/{1}" -f $key_vault, $new_Column_Master_Key)

New-SqlColumnMasterKey -Name $new_Column_Master_Key -InputObject $database -ColumnMasterKeySettings $column_master_settings
Add-AzureKeyVaultKey -VaultName $key_vault -Name $new_Column_Master_Key -Destination Software

Invoke-SqlColumnMasterKeyRotation -SourceColumnMasterKeyName $old_Column_Master_Key -TargetColumnMasterKeyName $new_Column_Master_Key -InputObject $database
Complete-SqlColumnMasterKeyRotation -SourceColumnMasterKeyName $old_Column_Master_Key  -InputObject $database
Remove-SqlColumnMasterKey -Name $old_Column_Master_Key -InputObject $database