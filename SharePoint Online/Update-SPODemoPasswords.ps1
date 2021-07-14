function Update-SPODemoPasswords{
<#  
 .SYNOPSIS 
  Updates all passwords except the administrator to a new password
   
 .DESCRIPTION 
  Using the Microsoft Office Demos you get 25 urers all with a know password, you can users
  this script to update those 25 urer accounts to a new password that isn't so well known
    
 .PARAMETER AdminUsers
  The username of the administrator account.  This is the account you DON''T want the password changed on 
 
 .PARAMETER NewPassword
  This is the password you want all 25 other accounts to be set to
    
 .EXAMPLE
  Update-SPODemoPasswords -admin admin@mydomain.onmicrosoft.com -newpassword 123abc!@# 
 
 .NOTES
 Author: Matthew McDermott
 Last Modifed By: Ben Stegink									   
 Date Created: 10-12-2015						   
 Last Modified: 10-12-2015
 Source: http://www.itunity.com/article/change-demo-users-passwords-2663
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$admin,  
    [parameter(Mandatory=$True,Position=2)][string]$newpassword
            
  )
  # This will pop-up a dialog and request your password
  $cred = Get-Credential -Credential $adminuser
  
  #——– Import the Local Microsoft Online PowerShell Module Cmdlets and Connect to O365 Online ———–
  Import-Module MSOnline Connect-MsolService -Credential $cred
  
  #Enumerate all users except Administrator
  Get-MsolUser | Where-Object {$_.UserPrincipalName -ine $adminuser} | foreach{ 
	  #Set their Password to something known 
	  Write-Host “Setting:” $_.UserPrincipalName
	  Set-MsolUserPassword –UserPrincipalName $_.UserPrincipalName –NewPassword $newpasswd -ForceChangePassword $false | Out-Null }
  }
}