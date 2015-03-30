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
  Converts a CSV file to an Excel (XLSX) file
   
 .DESCRIPTION 
  Converts a CSV file to an Excel (XLSX) file
    
 .PARAMETER inputfile
  Name of the CSV file being converted
 
 .PARAMETER output
  Name of the converted excel file , including the file extension

 .PARAMETER overwrite
  Boolean value to specify if you want to overwrite the output file if a file already exixts.  If
  true, any existing file with the same name will be overwrite.  If false, a prompt will be displayed
  asking if you want to overwirte the existing file.  This is set to be false by default
    
 .EXAMPLE 
  ConvertCSV-ToExcel -inputfile "C:\sample.csv" -output "C:\sample.csv"

 .EXAMPLE
  ConvertCSV-ToExcel -inputfile "C:\sample.csv" -output "C:\sample.csv" -overwrite $True
 
 .NOTES
 Original Author: Boe Prox
 Last Modified By: Ben Stegink									   
 Date Created: 								   
 Last Modified: 2015-03-30
   
#>
   
#Requires -version 2.0 
[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$inputfile,  
    [parameter(Mandatory=$True,Position=1)][string]$output,
    [parameter(Mandatory=$False)][Boolean]$overwrite = $False
            
  )
    
#Create Excel Com Object
$excel = new-object -com excel.application

#Show Excel application
$excel.Visible = $False
if($overwrite -eq $True){
    $excel.DisplayAlerts = $False
}
else{
    $excel.DisplayAlerts = $True
}

#Add workbook
$workbook = $excel.workbooks.open("$inputfile")

#Save the Converted Workbook
$workbook.saveas("$output",51)

#Close Excel
$excel.quit() 

}