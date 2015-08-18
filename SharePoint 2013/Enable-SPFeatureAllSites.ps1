function Enable-SPFeatureAllSites{
<#  
 .SYNOPSIS 
  Enables all Feature in a Site or a Site Collection
   
 .DESCRIPTION 
  Enables all Feature in a Site or a Site Collection
    
 .PARAMETER WebAppUrl
  This is some information of object that serves as as input
 
 .PARAMETER Scope
  This is some information or object that serves as as ouput to the fuction
  
 .PARAMETER FeatureID
  Specify the ID of the feature you want to activate. You must specify a Feature ID or a Feature Name.
  
 .PARAMETER Feature Name
  Specify the Name of the feature you want to activate. You must specify a Feature Name or a Feature ID.
      
 .EXAMPLE
 Enable-SPFeatureAllSites -WebAppUrl http://myWebApp -Scope Site -FeatureName "My Custom Feature" 
 
 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink									   
 Date Created: 8-17-2015						   
 Last Modified: 8-17-2015
 
 If you want to do it in two lines you can use the following,
 replace http://yourURL and [FeatureID] with values for your environment
 
 $s = Get-SPWebApplication http://yourURL | Get-SPSite -Limit ALL | foreach{$_.Url}
 $s |%{ if((Get-SPFeature -Identity [FeatureID] -Site $_ -ErrorAction SilentlyContinue) -eq $null){Write-Host "Enable Feature on $_";Enable-SPFeature -Identity [FeatureID] -URL $_}}
   
#>
[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$WebAppUrl,
    [parameter(Mandatory=$True,Position=2)][string]$Scope,  
    [parameter(Mandatory=$False,Position=3)][string]$FeatureID,
    [parameter(Mandatory=$False,Position=4)][string]$FeatureName
            
  )
  if($Scope -eq "Site"){}
    $sites = Get-SPWebApplication $WebAppUrl | Get-SPSite -Limit ALL | foreach{$_.Url}
    foreach($site in $sites){
      if((Get-SPFeature -Identity $FeatureID -Site $site -ErrorAction SilentlyContinue) -eq $null)
      {
        Write-Host "Enable Feature on $_"
        Enable-SPFeature -Identity $FeatureID  -URL $site
      }
    }
  }
  elseif($Scope -eq "Web"){
    
  }
  else{
    Write-Host "You must specify either Site or Web for the scope"
  }
}