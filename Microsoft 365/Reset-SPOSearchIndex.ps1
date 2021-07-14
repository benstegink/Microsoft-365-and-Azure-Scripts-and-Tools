param(
  [Parameter(Mandatory=$true,ValueFromPipeline=$true)]$url,
  [ValidateSet('skip','on','off')][System.String]$enableAllManagedProperties="skip"  )
# Re-index SPO tenant script, and enable ManagedProperties managed property
# Author: Mikael Svenson - @mikaelsvenson
# Blog: http://techmikael.blogspot.com

# Modified by Eric Skaggs on 10/21/2014 - had trouble running this script as it was; functionality has not been changed

##### UPDATES NEEDED #####
# Update Script to give user Site Collection admin access if they don't have it

function Reset-Webs( $siteUrl ) 
{
	Write-Host "Connecting to site: '$siteUrl'..."
	Connect-PnPOnline -Url $siteUrl -Credentials $credentials
	$ctx = Get-PnPContext
	if (!$ctx.ServerObjectIsNull.Value) 
	{ 
		Write-Host "Connected to SharePoint Online site: '$siteUrl'" -ForegroundColor Green 
	} 

	$rootWeb = Get-PnPWeb
	processWeb($rootWeb)	
}

function processWeb($web)
{
	$webUrl = $web.Url
	$undoNoScript = $false
	Connect-PnPOnline -Url $url -Credentials $credentials
	$site = Get-PnPTenantSite -Url $webUrl
	if($site.DenyAddAndCustomizePages -eq "Enabled"){
		Write-Host "Temporary enabling scripts on site: '$webUrl'" -ForegroundColor Yellow
		Set-PnPTenantSite -Url $webUrl -NoScriptSite:$false
		$undoNoScript = $true
	}
	Connect-PnPOnline -Url $webUrl -Credentials $credentials
	$subWebs = Get-PnPSubWebs
	$ctx.Load($web)		
	$ctx.Load($web.AllProperties)
	$ctx.ExecuteQuery()
	
	Write-Host "Web URL:" $web.Url -ForegroundColor White
	if( $enableAllManagedProperties -ne "skip" ) {
		Set-AllManagedProperties -web $web -clientContext $ctx -enableAllManagedProps $enableAllManagedProperties
	}
	
	[int]$version = 0
	$allProperties = $web.AllProperties
	if( $allProperties.FieldValues.ContainsKey("vti_searchversion") -eq $true ) {
		$version = $allProperties["vti_searchversion"]
	}
	$version++
	Set-PnPPropertyBagValue -Key "vti_searchversion" -Value $version
	Write-Host "-- Updated search version: " $version -ForegroundColor Green

	if($undoNoScript -eq $true){
		Write-Host "Undo temporary enabling of scripts on site: '$webUrl'" -ForegroundColor Yellow
		Connect-PnPOnline -Url $url -Credentials $credentials
		Set-PnPTenantSite -Url $webUrl -NoScriptSite:$true
		$undoNoScript = $false
		Connect-PnPOnline -Url $webUrl -Credentials $credentials
	}
	
	# No need to process subwebs if we only mark site collection for indexing
	if($enableAllManagedProperties -ne "skip") {
		foreach ($subWeb in $subWebs)
		{
			processWeb($subWeb)
		}
	}
}

function Set-AllManagedProperties( $web, $ctx, $enableAllManagedProps )
{
	$lists = $web.Lists
	$ctx.Load($lists)
    $ctx.ExecuteQuery()
 
    foreach ($list in $lists)
    {
        Write-Host "--" $list.Title
		
		if( $list.NoCrawl ) {
			Write-Host "--  Skipping list due to not being crawled" -ForegroundColor Yellow
			continue
		}
 
		$skip = $false;
		$eventReceivers = $list.EventReceivers
		$ctx.Load($eventReceivers)
		$ctx.ExecuteQuery()
		
		foreach( $eventReceiver in $eventReceivers )
		{
			if( $eventReceiver.ReceiverClass -eq "Microsoft.SharePoint.Publishing.CatalogEventReceiver" ) 
			{
				$skip = $true
				Write-Host "--  Skipping list as it's published as a catalog" -ForegroundColor Yellow
				break
			}
		}
		if( $skip ) {continue}
 
		$folder = $list.RootFolder
		$props = $folder.Properties
		$ctx.Load($folder)		
		$ctx.Load($props)
		$ctx.ExecuteQuery()
		
		if( $enableAllManagedProps -eq "on" ) {
			Write-Host "--  Enabling all managed properties" -ForegroundColor Green
			$props["vti_indexedpropertykeys"] = "UAB1AGIAbABpAHMAaABpAG4AZwBDAGEAdABhAGwAbwBnAFMAZQB0AHQAaQBuAGcAcwA=|SQBzAFAAdQBiAGwAaQBzAGgAaQBuAGcAQwBhAHQAYQBsAG8AZwA=|"
			$props["IsPublishingCatalog"] = "True"
		}
		if( $enableAllManagedProps -eq "off" ) {
			Write-Host "--  Disabling all managed properties" -ForegroundColor Green
			$props["vti_indexedpropertykeys"] = $null
			$props["IsPublishingCatalog"] = $null
		}
		$folder.Update()
		$ctx.ExecuteQuery()		
    }
}

$credentials = Get-AutomationPSCredential -Name 'Aptar-BenAdmin'
Connect-SPOService -Url $url -Credential $credentials
Get-SPOSite | % {Reset-Webs -siteUrl $_.Url }