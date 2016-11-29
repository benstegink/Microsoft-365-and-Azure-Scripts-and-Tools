$searchMachines = @("NavubaSP16App01","NavubaSP16WFE01")
$searchQueryMachines = @("NavubaSP16App01")
$searchCrawlerMachines = @("NavubaSP16App01")
$searchIndexMachines = @("NavubaSP16App01")
$searchContentProcessingMachines = @("NavubaSP16App01")
$searchAdminComponentMachine = "NavubaSP16App01"
$searchAnalyticsComponentMachine = "NavubaSP16App01"
$searchSAName = "Search Service Application"
$saAppPoolName = "SharePoint Service Applications"
$saAppPoolAccount = "navuba\spsvcapps"
$databaseServerName = "SP2016SQL"
$searchDatabaseName = "SP2016_ServiceApp_Search"


#Create Index Folder Location before running script
$indexLocation = "D:\SPIndex"
Write-Host "Starting Services"
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
    foreach ($machine in $searchMachines)
    {
        $searervechSr = (Get-ChildItem env:computername).value
        $srchInst = Get-SPEnterpriseSearchServiceInstance -Identity $machine
        if($srchInst.Status -ne "Online"){
            Write-Host "Starting Search Services on" $machine
            Start-SPEnterpriseSearchServiceInstance -Identity $machine
            #While($srchInst.Status -ne "Online"){
            #    Start-Sleep -Seconds 5
            #}
            Start-Sleep -Seconds 90
            if($srchInst.Status -ne "Online"){
                Start-Sleep -Seconds 30
            }
            Write-Host "Search Service Started on" $machine
        }
    }
    Write-Host "Creating Search Service and Proxy"
    $searchApp = Get-SPEnterpriseSearchServiceApplication -Identity $searchSAName -ErrorAction SilentlyContinue
    if (!$searchApp)
    {
        $searchApp = New-SPEnterpriseSearchServiceApplication -Name $SearchSAName -ApplicationPool $saAppPool -DatabaseServer $databaseServerName -DatabaseName $searchDatabaseName
    }
    $searchProxy = Get-SPEnterpriseSearchServiceApplicationProxy -Identity "$searchSAName Proxy" -ErrorAction SilentlyContinue
    if (!$searchProxy)
    {
        New-SPEnterpriseSearchServiceApplicationProxy -Name "$searchSAName Proxy" -SearchApplication $searchSAName
    }

    Write-Host "Defining the Search Topology"
    $initialSearchTopology = $searchApp | Get-SPEnterpriseSearchTopology -Active
    $newSearchTopology = $searchApp | New-SPEnterpriseSearchTopology

    Write-Host "Creating Admin Component"
    $searchInstance = Get-SPEnterpriseSearchServiceInstance -Identity $searchAdminComponentMachine
    New-SPEnterpriseSearchAdminComponent -SearchTopology $newSearchTopology -SearchServiceInstance $searchInstance

    Write-Host "Creating Analytics Component"
    $searchInstance = Get-SPEnterpriseSearchServiceInstance -Identity $searchAnalyticsComponentMachine
    New-SPEnterpriseSearchAnalyticsProcessingComponent -SearchTopology $newSearchTopology -SearchServiceInstance $searchInstance

    Write-Host "Creating Content Processing Component"
    foreach($machine in $searchContentProcessingMachines){
        $searchInstance = Get-SPEnterpriseSearchServiceInstance -Identity $machine
        New-SPEnterpriseSearchContentProcessingComponent -SearchTopology $newSearchTopology -SearchServiceInstance $searchInstance
    }

    Write-Host "Creating Query Processing Component"
    foreach($machine in $searchQueryMachines){
        $searchInstance = Get-SPEnterpriseSearchServiceInstance -Identity $machine
        New-SPEnterpriseSearchQueryProcessingComponent -SearchTopology $newSearchTopology -SearchServiceInstance $searchInstance
    }

    Write-Host "Creating Crawl Component"
    foreach($machine in $searchCrawlerMachines){
        $searchInstance = Get-SPEnterpriseSearchServiceInstance -Identity $machine
        New-SPEnterpriseSearchCrawlComponent -SearchTopology $newSearchTopology -SearchServiceInstance $searchInstance
    }

    Write-Host "Creating Index Component"
    foreach($machine in $searchIndexMachines){
        $indexComp = (New-Object Microsoft.Office.Server.Search.Administration.Topology.IndexComponent $machine,0)
        $indexComp.RootDirectory = $indexLocation
        $newSearchTopology.AddComponent($indexComp)
        #There is an issue with the lines below that has been identified by MS here - 
        #$searchInstance = Get-SPEnterpriseSearchServiceInstance -Identity $machine
        #New-SPEnterpriseSearchIndexComponent -SearchTopology $newSearchTopology -SearchServiceInstance $searchInstance -RootDirectory $indexLocation -IndexPartition 0
    }
    Write-Host "Activating the new topology and removing the old topology"
    Set-SPEnterpriseSearchTopology -Identity $newSearchTopology
    Remove-SPEnterpriseSearchTopology -Identity $initialSearchTopology -Confirm:$false
}
else{
    Write-Host "Couldn't retrieve Service Application Pool" $saAppPoolName
}