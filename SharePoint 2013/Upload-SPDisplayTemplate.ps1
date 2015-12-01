function Upload-SPDisplayTemplate{
<#  
 .SYNOPSIS 
  Uploads .html display template files to the Master Page Gallery Display Templates
   
 .DESCRIPTION 
  
  Available folders
  Content By Search(CBS) - content web parts
  Refinement Panel  - Filters 
    
 .PARAMETER templateFolder
  This is the folder in the "Display Templates" folder that you wish to upload your display templates to
 
 .PARAMETER multipleFiles
  Boolean - if this is true, -templates should be set to a folder, if this is false -templates should point
  to a single file
  
 .PARAMETER templates
  This is either a folder or a file based on the value passed to -multipleFiles
  
 .PARAMETER site
  URL of the Site Collection you want to upload the template to
    
 .EXAMPLE
  Update-SPDisplayTemplate -templateFolder "content web parts" -multipleFiles $false -templates "C:\displaytemplates\mytemplate.html" -siteUrl "http://intranet"
  
 .EXAMPLE
  Update-SPDisplayTemplate -templateFolder "Filters" -multipleFiles $true -templates "C:\displayteampltes" -siteUrl "http://intranet/sites/sitecollection"
 
 .NOTES
 Script Modified Version of one from http://blogs.msdn.com/b/armenk/archive/2013/12/11/upload-display-templates-to-all-sites-in-your-sharepoint-server-2013-farm.aspx
 Author: Ben Stegink
 Last Modifed By: Ben Stegink									   
 Date Created: 11-30-2015						   
 Last Modified: 11-30-2015
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$templateFolder,  
    [parameter(Mandatory=$True,Position=2)][boolean]$multipleFiles,
    [parameter(Mandatory=$True,Position=3)][string]$templates,
    [parameter(Mandatory=$TRUE,Position=4)][string]$siteUrl
            
  )

  if($multipleFiles -eq $true){
    $files = ([System.IO.DirectoryInfo] (Get-Item $templates)).GetFiles();
  }
  else{
    $file = Get-Item $templates
  }
  
  #Write-Output "Uploading template to " $siteUrl "...";
  
  $site = Get-SPSite $siteUrl
  $web = $site.OpenWeb();
  $folder = $web.GetFolder("_catalogs/masterpage/display templates/" + $templateFolder);
  
  if($multipleFiles -eq $true){  
    foreach($file in $files){   
      $stream = $file.OpenRead();
      $spfile = $folder.Files.Add($folder.Url + "/" + $file.Name, $stream, $true);
      $stream.Close();
    }
  }
  else{
    $stream = $file.OpenRead();
    $spfile = $folder.Files.Add($folder.Url + "/" + $file.Name, $stream, $true);
    $stream.Close();    
  }
  
  $web.Close();
  $web.Dispose();
}