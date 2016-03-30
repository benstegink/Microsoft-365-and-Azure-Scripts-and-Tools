function Undeclare-SPRecord{
<#  
 .SYNOPSIS 
  Undeclare a record in a SharePoint List or Library
   
 .DESCRIPTION 
  
    
 .PARAMETER inputfile
  This is some information of object that serves as as input
 
 .PARAMETER output
  This is some information or object that serves as as ouput to the fuction
    
 .EXAMPLE 
 
 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink									   
 Date Created: 3-29-2016						   
 Last Modified: 3-29-2016
 Site used as template for code: http://itgroove.net/mmman/2013/04/29/undeclare-a-single-record-in-a-list/
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$siteUrl,  
    [parameter(Mandatory=$True,Position=2)][string]$listName,
    [parameter(Mandatory=$True,Position=3)][string]$scope,
    [parameter(Mandatory=$false,Position=4)][string]$itemId
            
  )

    Start-SPAssignment -Global

    $web = Get-SPWeb $siteUrl
    $list = $web.lists[$listName].items
 
    if($scope -ne "All" -or $scope -ne "Item"){
        foreach ($item in $list)
        {
            $IsRecord = [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::IsRecord($Item)
            if($scope -eq "All"){
                 if ($IsRecord -eq $true){
                    Write-Host "Undeclared $($item.File.Name)"
                    [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::UndeclareItemAsRecord($Item)
                 }
             }
             elseif($scope -eq "Item"){
                if($item.Id -eq $itemId){
                    if ($IsRecord -eq $true){
                        Write-Host "Undeclared $($item.File.Name)"
                        [Microsoft.Office.RecordsManagement.RecordsRepository.Records]::UndeclareItemAsRecord($Item)
                    }
                }
             }
        }
    }
    else{
        Write-Host "Please specify either All or Item for the scope"
    }
    Stop-SPAssignment -Global
}
