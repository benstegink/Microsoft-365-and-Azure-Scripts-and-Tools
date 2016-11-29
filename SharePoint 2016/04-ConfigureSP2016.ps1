$usageSAName = "Usage and Health Data Collection Service"
$stateSAName = "State Service"
$stateServiceDBName = "SP2016_ServiceApp_State_Service"
$usageServiceDBName = "SP2016_ServiceApp_Usage_Service"
$dbServer = "SP2016SQL"
Set-SPUsageService -LoggingEnabled 1 -UsageLogLocation "F:\SPLogs\" -UsageLogMaxSpaceGB 2
$serviceInstance = Get-SPUsageService
New-SPUsageApplication -Name $usageSAName -DatabaseServer $dbServer -DatabaseName $usageServiceDBName -UsageService $serviceInstance > $null
$stateServiceDatabase = New-SPStateServiceDatabase -Name $stateServiceDBName
$stateSA = New-SPStateServiceApplication -Name $stateSAName -Database $stateServiceDatabase
New-SPStateServiceApplicationProxy -ServiceApplication $stateSA -Name "$stateSAName Proxy" -DefaultProxyGroup