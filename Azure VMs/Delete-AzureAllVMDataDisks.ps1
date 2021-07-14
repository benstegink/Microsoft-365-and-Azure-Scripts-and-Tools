function Delete-AzureAllVMDataDisks(){
<#  
 .SYNOPSIS 
  Deletes All Data Disks associated with a Virtual Machine in Azure
   
 .DESCRIPTION 
  Deletes All Data Disks associated with a Virtual Machine in Azure
    
 .PARAMETER ServiceName
  The Name of the Azure Service that the VM is hosted in
 
 .PARAMETER VMName
  The Name of the Virutal Name you want to delete the data disks on
    
 .EXAMPLE 
 Delete-AzureAllVMDataDisks -ServiceName "MyAzureSerivce" -VMName "MySQLServer"

 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink									   
 Date Created: 2015-07-08						   
 Last Modified: 2015-0708
   
#>

[CmdletBinding()] 
Param
  (  
    [parameter(Mandatory=$True,Position=1)][string]$ServiceName,  
    [parameter(Mandatory=$True,Position=2)][string]$VMName
            
  )

    $vmservice = Get-AzureVM -ServiceName $ServiceName
    $vm = $vmservice.VM | ? {$_.RoleName -eq $VMName}
    $disks = $vm.DataVirtualHardDisks
    for($i = 0; $i -lt $disks.Count){
        Remove-AzureDataDisk -Lun $disks[$i].LUN -VM $vm -DeleteVHD
    }
    Update-AzureVM -ServiceName $vmservice.Name -VM $vm -Name $vm.RoleName
}