function Get-SPOOD4B{
<#  
 .SYNOPSIS 
  Returns an array of all the OD4B sites in your Office 365 Tenant
   
 .DESCRIPTION 
  A more detailed description of what this function does
    
 .PARAMETER spoAdminUrl
  This is some information of object that serves as as input
 
 .PARAMETER spoAdminUser
  This is some information or object that serves as as ouput to the fuction
 
 .PARAMETER spoAdminPassword
  This is a secure string containing the password for the admin user to connect to Office 365

 .PARAMETER outputToFile
  A boolean indicateing if you want the array sent to a file or not, the default is false

 .PARAMETER path
  The path to the output file if outputToFile is set to True
    
 .EXAMPLE 
 
 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink									   
 Date Created: 3-28-2017						   
 Last Modified: 3-28-2017
 Derived from: https://technet.microsoft.com/en-us/library/dn911464.aspx
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$spoAdminUrl,  
    [parameter(Mandatory=$True,Position=2)][string]$spoAdminUser,
    [parameter(Mandatory=$True,Position=3)][securestring]$spoAdminPassword,
    [parameter(Mandatory=$False,Position=4)][boolean]$outputToFile=$False,
    [parameter(Mandatory=$False,Position=5)][string]$path
            
  )
  if($outputToFile -eq $true -and $path -eq $null){
    # Prompt for a path to save the file to
  }
  $loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
  $loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
  $loadInfo3 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.UserProfiles")

  $creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($spoAdminUser, $spoAdminPassword)
  $proxyAddress = "$spoAdminUrl/_vti_bin/UserProfileService.asmx?wsdl"
  $userProfileService = New-WebServiceProxy -Uri $proxyAddress -UseDefaultCredential $False
  $UserProfileService.Credentials = $creds

  $strAuthCookie = $creds.GetAuthenticationCookie($spoAdminUrl)
  $uri = New-Object System.Uri($spoAdminUrl)
  $container = New-Object System.Net.CookieContainer
  $container.SetCookies($uri,$strAuthCookie)
  $userProfileService.CookieContainer = $container

  $UserProfileResult = $userProfileService.GetUserProfileByIndex(-1)

  $NumProfiles = $userProfileService.GetUserProfileCount()

  $MySites = @()
  $i=0

  While($UserProfileResult.NextValue -ne -1){
    Write-Host "Examining profile $i of $NumProfiles"
    $Prop = $UserProfileResult.UserProfile | ? {$_.Name -eq "PersonalSpace"}
    $od4bUrl = $Prop.Values[0].Value
    if($od4bUrl){
        $MySites += ,$od4bUrl
    }
    $UserProfileResult = $userProfileService.GetUserProfileByIndex($UserProfileResult.NextValue)
    $i++
  }

  return $MySites
}