Function Release-Ref ($ref) 
  {
    ([System.Runtime.InteropServices.Marshal]::ReleaseComObject(
    [System.__ComObject]$ref) -gt 0)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers() 
  }




Function ConvertCSV-ToExcel
{
<#  
 .SYNOPSIS 
  Converts a CSV file to an Excel file
   
 .DESCRIPTION 
  Converts a CSV file to an Excel file
    
 .PARAMETER inputfile
  Name of the CSV file being converted
 
 .PARAMETER output
  Name of the converted excel file
    
 .EXAMPLE 
 
 .NOTES
 Author: Boe Prox									   
 Date Created: 								   
 Last Modified: 
   
#>
   
#Requires -version 2.0 
[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$False,Position=1)][string]$inputfile,  
    [parameter(Mandatory=$False,Position=1)][string]$output
            
  )
    
#Create Excel Com Object
$excel = new-object -com excel.application

#Show Excel application
$excel.Visible = $True

#Add workbook
$workbook = $excel.workbooks.Add()

#Use the first worksheet in the workbook
$worksheet1 = $workbook.worksheets.Item(1)

#Remove other worksheets that are not needed
$workbook.worksheets.Item(2).delete()
$workbook.worksheets.Item(2).delete()

#Start row and column
$r = 1
$c = 1

#Begin working through the CSV
$file = (GC $inputfile)
ForEach ($f in $file) {
  $arr = ($f).split(',')
  ForEach ($a in $arr) {
    $worksheet1.Cells.Item($r,$c) = "$(($a).replace('"',))"
    $c++
    }
  $c = 1
  $r++    
  }    

#Select all used cells
$range = $worksheet1.UsedRange

#Autofit the columns
$range.EntireColumn.Autofit() | out-null 

#Save spreadsheet
$workbook.saveas("$pwd\$output")

Write-Host -Fore Green "File saved to $pwd\$output"

#Close Excel
$excel.quit() 

#Release processes for Excel
$a = Release-Ref($range)
$a = Release-Ref($worksheet1)
$a = Release-Ref($workbook)
$a = Release-Ref($range)
}