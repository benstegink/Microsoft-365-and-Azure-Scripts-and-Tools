#--------------------------------------------------------------------------------------- 
# Name:            Set-WebApplicataionPool.ps1 
# Description:     This script will change SP WebApplication Pools for a Web Application 
#                 
# Usage:        Run the function with the required parameters 
# By:             Ivan Josipovic, Softlanding.ca 
#--------------------------------------------------------------------------------------- 
Function Set-WebApplicataionPool{
<#  
 .SYNOPSIS 
  This function can be used to set/change the application pool for a SharePoint Web Application
   
 .DESCRIPTION 
  This function can be used to set/change the application pool for a SharePoint Web Application
    
 .PARAMETER WebAppURL
  This is the URL of the web applicaiton you want to set the Application Pool for
 
 .PARAMETER Application Pool Name
  The is the name of the Application Pool you want to set your web application to use
    
 .EXAMPLE 
 Set-WebApplicataionPool -WebAppURL "http://demo" -ApplicationPoolName "SharePoint Web Applications"
 .NOTES
 Author: Ivan Josipovic, Softlanding.ca 
 Last Modifed By: Ben Stegink									   
 Date Created: 2015-07-08						   
 Last Modified: 2015-07-08
   
#>
[CmdletBinding()] 
  Param
    (  
      [parameter(Mandatory=$True,Position=1)][string]$WebAppURL,  
      [parameter(Mandatory=$True,Position=2)][string]$$ApplicationPoolName)
            
    )
   
    $apppool = [Microsoft.SharePoint.Administration.SPWebService]::ContentService.ApplicationPools | where {$_.Name -eq $ApplicationPoolName} 
    if ($apppool -eq $null){ 
        write-host -foreground red "The Application Pool $ApplicationPoolName does not exist!" 
        return 1 
    } 
    $webapp = get-spwebapplication -Identity $WebAppUrl 
    if ($webapp -eq $null){ 
        write-host -foreground red "The Web Application $WebAppUrl does not exist!" 
        return 1 
    } 
    $webapp.Applicationpool = $apppool 
    $webApp.Update() 
    $webApp.ProvisionGlobally() 
    write-host -foreground green "$WebappURL Application Pool has been changed to $ApplicationPoolName" 
    return 0 
} 