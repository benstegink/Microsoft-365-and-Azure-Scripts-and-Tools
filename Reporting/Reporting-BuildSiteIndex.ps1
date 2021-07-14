$reportingCred = Get-AutomationPSCredential -Name 'PowerShellAdmin'
$sqlCred = Get-AutomationPSCredential -Name 'SQLReporting'
$SiteIndexDB = Get-AutomationVariable -Name 'Reporting_SiteIndexDB'
$tenantAdminUrl = Get-AutomationVariable -Name 'Reporting_TenantAdminUrl'
$tenantRootUrl = Get-AutomationVariable -Name 'Reporting_TenantRootUrl'

Connect-PnPOnline -Url $tenantRootUrl -Credentials $reportingCred
Connect-SPOService -Url $tenantAdminUrl -Credential $reportingCred


# SQL Connection
$con = New-Object System.Data.SQLClient.SqlConnection

$SQLuser = $sqlCred.Username
$SQLpwd = $sqlCred.GetNetworkCredential().Password


$con.ConnectionString = "Server=tcp:intelliginkdemos.database.windows.net;Database=O365Reporting;User ID=$SQLuser;Password=$SQLpwd;Trusted_Connection=False;Encrypt=True;"
$con.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.Connection = $con

$sites = Get-SPOSite
foreach($site in $sites){
    if($site.Url -match "/sites/" -or $site.Url -match "/teams/" -or $site.Url -eq $tenantRootUrl ){
        $siteTitle = $null
        $siteUrl = $null
        Connect-PnPOnline -Url $site.Url -Credentials $reportingCred
        $site = Get-PnPSite
        $site.Context.Load($site.Rootweb)
        $site.Context.ExecuteQuery()
        $rootweb = Get-PnPWeb
        $rootweb.Context.ExecuteQuery()
        $webs = Get-PnPSubWebs
        $allwebs = $webs += $rootweb
        foreach($web in $allwebs){
            $guid = [guid]::NewGuid()
            $SiteID = $guid.Guid
            $SiteUrl = $web.Url
            $cmd.CommandText = "if not exists (select * from $SiteIndexDB where SiteUrl = '{1}' ) `
            begin `
            INSERT INTO $SiteIndexDB (SiteID,SiteURL) VALUES('{0}','{1}') `
            end" `
            -f $SiteID,$SiteURL
            $cmd.ExecuteNonQuery()
        }
    }   
}