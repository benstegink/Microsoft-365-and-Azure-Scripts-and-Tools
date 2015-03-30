function Upload-FileToDocLibrary{
<#  
 .SYNOPSIS 
  Upload a File to a SharePoint Library
   
 .DESCRIPTION 
  In order to load this function into your current session run PS>. ./Upload-FileToDocLibrary.sp1
  Once this command has been run you can use this fuction in your current session just like any other cmdlet.
  Currently this is a very basic fuction, it doesn't include the option for including any metadata and may cause issues if
  you have Checkin/Checkout enabled on the library this function uses.  I'll try to update this script to include a broader
  range of support.
    
 .PARAMETER filePath
  This is the full path of the file.  i.e. C:\Folder\File.txt
 
 .PARAMETER siteUrl
  This is the url to the SharePoint site you want to upload the file to.  i.e. http://intranet/subsite

 .PARAMETER libraryName
  This is the name of the document libarary the file should be uplaoded to. i.e. Documents
    
 .EXAMPLE 
 Upload-FileToDocLibrary -filePath "C:\Folder\file.txt" -siteURL "http://intranet/subsite" -libraryName "Documents"
 
 .NOTES
 Author: Ben Stegink									   
 Date Created: Yesterday						   
 Last Modified: Today
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$filePath,  
    [parameter(Mandatory=$False,Position=1)][string]$siteUrl,
    [parameter(Mandatory=$True,Position=1)][string]$libraryName
            
  )
  
  #Web Site where you want to upload the file
  $web = Get-SPWeb -Identity $siteUrl
  #Library you want to upload the file too
  $lib = $web.Lists[$libraryName]

  if($lib -eq $null){
    return $False;
  }
  else{
    if([System.IO.File]::Exists($filePath) -eq $True){
        $file = Get-Item $filePath
        $stream = $file.OpenRead()
        $folder = $lib.RootFolder
        $folder.Files.Add("",$stream)
        return $True
    }
    else{
        return $False
    }
  }
}