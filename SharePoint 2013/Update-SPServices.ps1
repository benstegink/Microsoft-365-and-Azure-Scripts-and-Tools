function Update-SPServices{
<#  
 .SYNOPSIS 
  Used to Stop or Start all SharePoint Services that would have a connection to the SharePoint Databases
   
 .DESCRIPTION 
  Used to Stop or Start all SharePoint Services that would have a connection to the SharePoint Databases. This is ideal for when you want to work on your database servers and need to close all connections to those databases.
    
 .PARAMETER action
  Takes a string input of either Start or Stop to change the status of the services
 
 .EXAMPLE
  Update-SPServices -action Start
  
  .EXAMPLE
  Update-SPServices -action Stop  
 
 .NOTES
 Author: Shola Adegunle - https://sholaadegunle.wordpress.com/2014/02/04/sharepoint-2013-stopstart-services-to-stop-database-connections-to-sql/
 Last Modifed By: Ben Stegink									   
 Date Created: 2015-07-15						   
 Last Modified: 2015-07-15
 
 Updates to be made:
  - In the case of a server farm, pass an array of servers to the function to remotely stop the services on all servers in the farm.  
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$action,  
            
  )
  if($action -eq "Stop"){
    #Stop SharePoint Windows services and IIS
    $SPservices = “SPAdminV4″, “SPTimerV4″, “SPTraceV4″, “SPUserCodV4″, “SPWriterV4″, “W3SVC”, “OSearch15″
    foreach ($STservices in $SPservices)
    {
      Write-Host -ForegroundColor red “Stopping $STservices …”
	  Stop-Service -Name $STservices
    }
    iisreset /stop
  }
  elseif($action -eq "Start"){
	#Start SharePoint Windows services and IIS
	$SPservices = “SPAdminV4″, “SPTimerV4″, “SPTraceV4″, “SPUserCodV4″, “SPWriterV4″, “W3SVC”, “OSearch15″
	foreach ($STservices in $SPservices)
	{
		Write-Host -foregroundcolor green “Starting $STservices …”
		Start-Service -Name $STservices
	}
	iisreset /start
  }
  else{
	  Write-Host ($action + " is invalid, please use Start or Stop"
  }
}