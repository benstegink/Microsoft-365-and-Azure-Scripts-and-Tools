$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")

$siteUrl =  Read-Host -Prompt "SiteURL"
$username = Read-Host -Prompt "Enter username" 
$password = Read-Host -Prompt "Enter password" -AsSecureString

$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $password) 
$ctx.Credentials = $credentials
$featureId = [GUID]"2c63df2b-ceab-42c6-aeff-b3968162d4b1"
$featureDefinitionScope = [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None

$web = $ctx.Site.RootWeb
$ctx.Load($web)
$ctx.ExecuteQuery()
$features = $web.Features
$ctx.Load($features)
$ctx.ExecuteQuery()
$features.Add($featureId, $true, $featureDefinitionScope)
$ctx.ExecuteQuery()

