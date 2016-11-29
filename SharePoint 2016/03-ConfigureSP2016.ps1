# Add a SharePoint Server to the 2016 Farm

$DBServer = "SP2016SQL"
$ConfigDB = "SP2016_Config"
$AdminContentDB = "SP2016_Content_Admin"
$Passphrase = "sharepoint"
$distCacheHost = $false

if($distCacheHost -eq $false){
    Connect-SPConfigurationDatabase -DatabaseServer $DBServer -DatabaseName $ConfigDB -Passphrase (ConvertTo-SecureString $PassPhrase -AsPlainText -Force) `
    -LocalServerRole ApplicationWithSearch -SkipRegisterAsDistributedCacheHost
}
elseif($distCacheHost -eq $true){
        Connect-SPConfigurationDatabase -DatabaseServer $DBServer -DatabaseName $ConfigDB -Passphrase (ConvertTo-SecureString $PassPhrase -AsPlainText -Force) `
    -LocalServerRole ApplicationWithSearch
}

PSConfig.exe -cmd upgrade -inplace b2b -wait -cmd applicationcontent -install -cmd installfeatures -cmd secureresources -cmd services -install