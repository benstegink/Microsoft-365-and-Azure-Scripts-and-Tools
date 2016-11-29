$DBServer = "SP2016SQL"
$ConfigDB = "SP2016_Config"
$AdminContentDB = "SP2016_Content_Admin"
$Passphrase = "sh@r3p01nt"
$distCacheHost = $false

$farmadminCred = Get-Credential

if($distCacheHost -eq $false){
    New-SPConfigurationDatabase -DatabaseServer $DBServer -DatabaseName $ConfigDB -AdministrationContentDatabaseName $AdminContentDB `
-FarmCredentials $farmadminCred -Passphrase (ConvertTo-SecureString $PassPhrase –AsPlaintext –Force) -LocalServerRole ApplicationWithSearch -SkipRegisterAsDistributedCacheHost

}
elseif($distCacheHost -eq $true){
    New-SPConfigurationDatabase -DatabaseServer $DBServer -DatabaseName $ConfigDB -AdministrationContentDatabaseName $AdminContentDB -FarmCredentials $farmadminCred -Passphrase (ConvertTo-SecureString $PassPhrase –AsPlaintext –Force)
}