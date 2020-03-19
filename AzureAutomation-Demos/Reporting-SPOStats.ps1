$reportingCred = Get-AutomationPSCredential -Name 'PowerShellAdmin'
$sqlCred = Get-AutomationPSCredential -Name 'SQLReporting'
$tenantAdminUrl = Get-AutomationVariable -Name 'Reporting_TenantAdminUrl'
$ListsDB = Get-AutomationVariable -Name 'Reporting_ListsDB'
$SiteGrowthDB = Get-AutomationVariable -Name 'Reporting_SiteGrowthDB'
$SiteIndexDB = Get-AutomationVariable -Name 'Reporting_SiteIndexDB'
$SitesDB = Get-AutomationVariable -Name 'Reporting_SitesDB'

##### Functions #####
function Get-SPSiteCollectionSize([string]$StorageUnit,[decimal]$usageGB){
    $usageTotal = 0
    if($StorageUnit = "GB"){
        $usageTotal = $usageGB/1024
    }
    elseif($StorageUnit = "TB"){
        $usageTotal = $usageGB/1048576
    }
    return $usageTotal
}

function Get-ListInformation($siteUrl,$siteID){
    Connect-PnPOnline -Url $siteUrl -Credentials $reportingCred
    $web = Get-PnPWeb
    $web.Context.Load($web.Lists)
    $web.Context.ExecuteQuery()
    $lists = $web.Lists
    foreach($list in $lists){
        $list = Get-PnPList $list
        if($list.IsCatalog -eq $false -and ($list.BaseType -eq "DocumentLibrary" -or $list.BaseType -eq "MySiteDocumentLibrary") `
         -and $list.EntityTypeName -ne "FormServerTemplates" -and $list.IsApplicationList -ne $true -and ($list.BaseTemplate -eq "101" -or $list.BaseTemplate -eq "1302")){
            [int]$itemcount += $list.ItemCount
            #Write-Output "The new item count is: $itemcount"
            $lastModified = $list.LastItemUserModifiedDate
            $listId = $list.Id.Guid.ToString()
            $Title = $list.Title
            [int]$ListItemCount = $list.ItemCount
            #Write-Output $lastModified $listId $siteID $Title $ListItemCount
            $cmd.CommandText = "if exists (select * from $ListsDB where SiteId = '{0}' AND ListId = '{1}') `
            begin `
            update $ListsDB Set ListTitle='{2}',ListItemCount='{3}',ListItemLastModified='{4}' `
            where SiteId = '{0}' AND ListId = '{1}' `
            end `
            else `
            begin `
            INSERT INTO $ListsDB (SiteID,ListID,ListTitle,ListItemCount,ListItemLastModified) VALUES('{0}','{1}','{2}','{3}','{4}') `
            end" `
            -f $SiteID,$listId,$Title,$ListItemCount,$lastModified
            [void] $cmd.ExecuteNonQuery()
        }
    }
}


function Get-SiteCollectionStats($siteID,$siteUrl){
    Connect-SPOService $tenantAdminUrl -Credential $reportingCred
    Connect-PnPOnline -Url $siteUrl -Credentials $reportingCred
    $site = Get-PnpSite
    $spoSite = Get-SPOSite $siteUrl
    $usage = $spoSite.StorageUsageCurrent
    $webs = Get-PnPSubWebs -Recurse
    $subwebCount = $webs.Count
    $date = Get-Date
    #Write-Output "Get storage size"
    $storageSize = Get-SPSiteCollectionSize -StorageUnit "GB" -usageGB $usage
    #Write-Output $storageSize
    #Write-Output "Get document count"
    #$items = Get-SPSiteCollectionDocuments -siteUrl $siteUrl -siteID $siteID
    $items=0
    Write-Output "Start"
    Write-Output $SiteID $date $storageSize $items $subwebCount
    Write-Output "Stop"
    $cmd.CommandText = "INSERT INTO $SiteGrowthDB (SiteId,UpdateDate,StorageSize,SiteItemCount,SubWebCount) VALUES('{0}','{1}','{2}','{3}','{4}')" `
    -f $SiteID,$date,$storageSize,$items,$subwebCount
    [void] $cmd.ExecuteNonQuery()
}


##### End Functions #####

# SQL Connection
$con = New-Object System.Data.SQLClient.SqlConnection

$SQLuser = $sqlCred.Username
$SQLpwd = $sqlCred.GetNetworkCredential().Password

$ConnectionString = "Server=tcp:intelliginkdemos.database.windows.net;Database=O365Reporting;User ID=$SQLuser;Password=$SQLpwd;Trusted_Connection=False;Encrypt=True;"
$query = "select * from $SiteIndexDB"
$con = New-Object system.data.SqlClient.SQLConnection
$con.ConnectionString = $ConnectionString
$con.Open()

$cmd = New-Object System.Data.SqlClient.SqlCommand($query,$con)

$adapter = New-Object System.data.sqlclient.sqlDataAdapter $cmd
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataset) | Out-Null


$sites = $dataSet.Tables.Rows
#End SQL

foreach($item in $sites){
    $siteTitle = $null
    $siteURL = $item.SiteURL
    Write-Output "Site URL is $siteURL"
    Connect-PnPOnline -Url $siteURL -Credentials $reportingCred
    $site = Get-PnPSite
    $lastitemmodifed = $site.LastContentModifiedDate
    $site.Context.Load($site.Rootweb)
    $site.Context.ExecuteQuery()
    $web = Get-PnPWeb
    $web.Context.Load($web)
    $web.Context.Load($web.AllProperties)
    $web.Context.ExecuteQuery()
    if($web.Url -eq $site.RootWeb.Url){
        $SiteCollection = $True
    }
    else{
        $Sitecollection = $False
    }
    $SiteID = $item.SiteID
    $SiteUrl = $web.Url
    $Sitetitle = $web.Title
    $lastitemmodifed = $web.LastItemUserModifiedDate
    $dateCreated = $web.Created
    $cmd.CommandText = "if exists (select * from $SitesDB where SiteId = '{0}' ) `
        begin `
        update $SitesDB Set SiteUrl='{1}',SiteTitle='{2}',LastItemModified='{3}',SiteCollection='{5}' `
        where SiteId = '{0}' `
        end `
        else `
        begin `
        INSERT INTO $SitesDB (SiteID,SiteURL,SiteTitle,LastItemModified,DateAdded,SiteCollection) VALUES('{0}','{1}','{2}','{3}','{4}','{5}') `
        end" `
        -f $SiteID,$SiteURL,$siteTitle,$lastitemmodifed,$dateCreated,$SiteCollection
    $cmd.ExecuteNonQuery()
    Get-ListInformation -SiteID $siteID -siteUrl $siteURL
    if($siteCollection -eq $True){
        Get-SiteCollectionStats -SiteID $siteID -siteUrl $site.Url
    }
}

$con.Close()
