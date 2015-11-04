function Create-CredentialFile{
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
  $session = New-PSSession -ComputerName [computername] -Credential $cred
  Invoke-Command -Session $session -ScriptBlock {hostname;Add-PSSnapin microsoft.sharepoint.powershell;(Get-SPFarm).Servers}

 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink                                      
 Date Created: Yesterday                           
 Last Modified: Today
   
#>
    [CmdletBinding()] 
    Param
      ( [parameter(Mandatory=$True,Position=1)][string]$type, 
        [parameter(Mandatory=$False,Position=2)][string]$domain,  
        [parameter(Mandatory=$True,Position=3)][string]$username,
        [parameter(Mandatory=$True,Position=4)][string]$fileLocation = "C:\",
        [parameter(Mandatory=$False,Position=5)][string]$fileName
                
      )
    #STORED CREDENTIAL CODE
    if($fileName -eq $Null){
        $CredsFile = $fileLocation + "\" + $AdminName + "-PowershellCreds.txt"
    }
    else{
        $CredsFile = $fileLocation + "\" + $fileName
    }
    $FileExists = Test-Path $CredsFile
    if  ($FileExists -eq $false) {
        Write-Host 'Credential file not found. Enter your password:' -ForegroundColor Red
        Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
        $password = get-content $CredsFile | convertto-securestring
        if($type -eq "NTLM"){
          $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $domain\$username,$password
        }
        if($type -eq "SQL"){
          $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password  
        }
    }
    else {
        Write-Host 'Using your stored credential file' -ForegroundColor Green
        $password = get-content $CredsFile | convertto-securestring
        if($type -eq "NTLM"){
          $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $domain\$username,$password
        }
        if($type -eq "SQL"){
          $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password  
        }
    }
    sleep 2
    Write-Host 'Credential File Created'

}