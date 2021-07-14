$UserCredential = Get-AutomationPSCredential -Name 'PowerShellAdmin'
$sqlCred = Get-AutomationPSCredential -Name 'SQLReporting'
$ExchangeStatsDB = Get-AutomationVariable -Name 'Reporting_ExchangeStatsDB'
$ExchangeMailboxGrowthDB = Get-AutomationVariable -Name 'Reporting_ExchangeGrowthDB' 

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global

#SQL Connection
$con = New-Object System.Data.SQLClient.SqlConnection

$SQLuser = $sqlCred.Username
$SQLpwd = $sqlCred.GetNetworkCredential().Password

$ConnectionString = "Server=tcp:intelliginkdemos.database.windows.net;Database=O365Reporting;User ID=$SQLuser;Password=$SQLpwd;Trusted_Connection=False;Encrypt=True;"
$con = New-Object system.data.SqlClient.SQLConnection
$con.ConnectionString = $ConnectionString
$con.Open()

$cmd = New-Object System.Data.SqlClient.SqlCommand($query,$con)
#End SQL Connection

$mailboxes = Get-Mailbox -ResultSize Unlimited
foreach($mb in $mailboxes){
    $stats = Get-MailboxStatistics $mb.PrimarySmtpAddress
    $priSMTP = $mb.PrimarySmtpAddress
    Write-Output "checking mailbox for $priSMTP"
    if($mb.IsInactiveMailbox -eq $False){
        Write-Output "getting mailbox size for $priSMTP"
        $name = $stats.displayname
        $size = $stats.totalitemsize.value.ToString()
        $size = $size.Substring($size.IndexOf("(")+1,$size.Length - $size.IndexOf("(")-8)
        $size = [decimal]$size
        $items = [int]$stats.ItemCount
        $date = Get-Date
        Write-Output "$name; $size"

        $cmd.CommandText = "if exists (select * from $ExchangeStatsDB where UserUPN = '{0}' ) `
            begin `
            update $ExchangeStatsDB Set MailboxSize='{1}',MailItems='{2}' `
            where UserUPN = '{0}' `
            end `
            else `
            begin `
            INSERT INTO $ExchangeStatsDB (UserUPN,MailboxSize,MailItems) VALUES('{0}','{1}','{2}') `
            end" `
            -f  $priSMTP,$size,$items
        $cmd.ExecuteNonQuery()

        $cmd.CommandText = "INSERT INTO $ExchangeMailboxGrowthDB (UserUPN,MailboxSize,MailItems,UpdateDate) VALUES('{0}','{1}','{2}','{3}')" `
            -f  $priSMTP,$size,$items,$date
        $cmd.ExecuteNonQuery()

    }
    else{
        Write-Output "The mailbox/account for $priSMTP is Inactive"
    }
}

Exit-PSSession $Session






<#function Get-ListInformation($siteUrl,$siteID){
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
            $cmd.CommandText = "if exists (select * from Lists where SiteId = '{0}' AND ListId = '{1}') `
            begin `
            update Lists Set ListTitle='{2}',ListItemCount='{3}',ListItemLastModified='{4}' `
            where SiteId = '{0}' AND ListId = '{1}' `
            end `
            else `
            begin `
            INSERT INTO Lists (SiteID,ListID,ListTitle,ListItemCount,ListItemLastModified) VALUES('{0}','{1}','{2}','{3}','{4}') `
            end" `
            -f $SiteID,$listId,$Title,$ListItemCount,$lastModified
            [void] $cmd.ExecuteNonQuery()
        }
    }
}#>