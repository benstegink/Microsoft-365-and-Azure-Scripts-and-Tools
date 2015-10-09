function Verb-Noun{
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
 
 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink									   
 Date Created: 4-13-2015						   
 Last Modified: 4-13-2015
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$inputparam,  
    [parameter(Mandatory=$False,Position=2)][string]$input2param
            
  )

  $outputvalue = ($inputparam + $input2param)

  return $outputvalue
}