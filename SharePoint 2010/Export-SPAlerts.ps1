function Export-SPAlerts{
<#  
 .SYNOPSIS 
  Does Something
   
 .DESCRIPTION 
  A more detailed description of what this function does
    
 .PARAMETER inputfile
  This is some information of object that serves as as input
 
 .PARAMETER output
  This is some information or object that serves as as ouput to the fuction
    
 .EXAMPLE 
 
 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink									   
 Date Created: 4-13-2015						   
 Last Modified: 4-13-2015
 Original Source/Idea: https://gist.github.com/nlarkin/5067267
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$url,  
    [parameter(Mandatory=$False,Position=2)][string]$CSVFileName
            
  )
##################################################################################################
# Load SharePoint Snapin
##################################################################################################
$snap = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'} 
if ($snap -eq $null) { 
  Write-Host "Loading Powershell Snapin..." -ForegroundColor Yellow
	Add-PSSnapin Microsoft.SharePoint.Powershell 
}

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") | Out-Null


##################################################################################################
# Global Variables
##################################################################################################
$Today = [string]::Format( "{0:yyyy-MM-dd}", [datetime]::Now.Date )


$SiteCollectionUrl = $url
$RootWeb = get-spweb $SiteCollectionUrl

if($CSVFileName -eq $null -or $CSVFileName -eq ""){
	$CSVFileName= "$Today - Excel Export User Alerts.csv"
}


$ErrorActionPreference="SilentlyContinue"
$ErrorActionPreference = "Continue"

Write-Host "##########################################################################################" -ForegroundColor Yellow
Write-Host "# $Today - Running User Alerts Export Script" -ForegroundColor Yellow
Write-Host "##########################################################################################" -ForegroundColor Yellow
Write-Host ""

$AllAlerts= @()

##################################################################################################
# Loop through sites
# This loop needs some work and needs some options added to it
# Configure so it will loop through the entire farm, subsites or just a single site
# Might require another parameter or two for the function as well
##################################################################################################
foreach ($web in $RootWeb.Webs) 
{
	$web = $RootWeb
	Write-Host ("Exporting Alerts for site: "+$web.Title)
	$webalerts = 0
	
	foreach($alert in $web.Alerts)
	{
	$alertobj = New-Object System.Object
	$alertobj | Add-Member -type NoteProperty -name ParentSite -value $web.Title
	$alertobj | Add-Member -type NoteProperty -name ParentUrl -value $web.Url
	$alertobj | Add-Member -type NoteProperty -name Title -value $alert.title	
	$alertobj | Add-Member -type NoteProperty -name List -value $alert.List
	$alertobj | Add-Member -type NoteProperty -name ListUrl -value $alert.ListUrl
	$alertobj | Add-Member -type NoteProperty -name ListID -value $alert.ListID
	$alertobj | Add-Member -type NoteProperty -name User -value $alert.user
	$alertobj | Add-Member -type NoteProperty -name UserID -value $alert.userID
	$alertobj | Add-Member -type NoteProperty -name AlertFrequency -value $alert.AlertFrequency
	$alertobj | Add-Member -type NoteProperty -name AlertTime -value $alert.AlertTime
	$alertobj | Add-Member -type NoteProperty -name AlertType -value $alert.AlertType
	$alertobj | Add-Member -type NoteProperty -name AlwaysNotify -value $alert.AlwaysNotify
	$alertobj | Add-Member -type NoteProperty -name AlertTemplate -value $alert.AlertTemplate
	$alertobj | Add-Member -type NoteProperty -name AlertTemplateName -value $alert.AlertTemplateName
	$alertobj | Add-Member -type NoteProperty -name DeliveryChannels  -value $alert.DeliveryChannels 
	$alertobj | Add-Member -type NoteProperty -name EventType  -value $alert.EventType 
	$alertobj | Add-Member -type NoteProperty -name EventTypeBitmask  -value $alert.EventTypeBitmask
	$alertobj | Add-Member -type NoteProperty -name 'Filter'  -value $alert.Filter
	$alertobj | Add-Member -type NoteProperty -name ID  -value $alert.ID
	$alertobj | Add-Member -type NoteProperty -name Item  -value $alert.Item
	$alertobj | Add-Member -type NoteProperty -name ItemID  -value $alert.ItemID
	$alertobj | Add-Member -type NoteProperty -name Status  -value $alert.Status
	$alertobj | Add-Member -type NoteProperty -name p_query -value $alert.Properties["p_query"]
	$alertobj | Add-Member -type NoteProperty -name eventtypeindex -value $alert.Properties["eventtypeindex"]
	$alertobj | Add-Member -type NoteProperty -name filterindex -value $alert.Properties["filterindex"]
	$alertobj | Add-Member -type NoteProperty -name p_lastnotificationtime -value $alert.Properties["p_lastnotificationtime"]
	$alertobj | Add-Member -type NoteProperty -name sendurlinsms -value $alert.Properties["sendurlinsms"]
	$alertobj | Add-Member -type NoteProperty -name siteurl -value $alert.Properties["siteurl"]

	$AllAlerts += , $alertobj
	$webalerts ++
	}
	
	Write-Host ($webalerts.ToString() +" Alert(s) Found`n`n"	)
}

##################################################################################################
# Export to csv
##################################################################################################
$AllAlerts | Export-Csv -NoTypeInformation  $CSVFileName
$num = ($AllAlerts).count

#end
Write-Host "Exported $num alerts." -ForegroundColor Yellow
Write-Host "Script Complete.`n`n" -ForegroundColor Yellow
}