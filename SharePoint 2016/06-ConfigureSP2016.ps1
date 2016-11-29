$saMetaDataServiceAppName = "Managed Metadata Service Application"
$saAppPoolName = "SharePoint Service Applications"
$saAppPoolAccount = "navuba\spsvcapps"
$saAdminUserName = "navuba\spadmin"
$dbServerName = "SP2016SQL"
$dbName = "SP2016_ServiceApp_ManagedMetadata"
$ctHubUrl = "http://cth.navuba.loc"

$saManagedAccount = Get-SPManagedAccount -Identity $saAppPoolAccount
if($saManagedAccount -eq $null){
    $cred = Get-Credential
    $saManagedAccount = New-SPManagedAccount -Credential $cred
}

$saAppPool = Get-SPServiceApplicationPool | ? {$_.Name -eq $saAppPoolName}
if($saAppPool -eq $null){
    $saAppPool = New-SPServiceApplicationPool -Name $saAppPoolName -Account $saManagedAccount
}
if($saAppPool -ne $null){

$cthub = Get-SPSite $ctHubUrl
if($site -eq $null){
    
}

$mmdServiceApp = New-SPMetadataServiceApplication -Name $saMetaDataServiceAppName -DatabaseServer $dbServerName -DatabaseName $dbName `
  -ApplicationPool $saAppPool -AdministratorAccount $saAdminUserName -HubUri $ctHubUrl -FullAccessAccount $saAdminUserName -SyndicationErrorReportEnabled

New-SPMetadataServiceApplicationProxy -Name "$saMetaDataServiceAppName Proxy" -ServiceApplication $mmdServiceApp `
 -DefaultProxyGroup -ContentTypePushdownEnabled -ContentTypeSyndicationEnabled

Start-SPService -Identity "Managed Metadata Web Service"

}
else{
    Write-Host "Couldn't retrieve Service Application Pool" $saAppPoolName
}