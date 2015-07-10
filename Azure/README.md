# Azure Script Index

Before running any of the scripts, make sure to Download and Install Azure PowewrShell from the [Microsoft Web Platform Installer](http://go.microsoft.com/fwlink/p/?linkid=320376&clcid=0x409).

Once that has been installed, from within Azure PowerShell, run the command -Add-AzureAccount- to connect to your Azure subscription

![https://l3oltq-sn3301.files.1drv.com/y2pzikUXZKFXchVQwZT-_pMzIlIGC2xzLI34bkg6wVgdepA64KIGaH-xt6NnZDfJPVqkutiuxdoSvU2S1Gn045_WSw0-cBuBQeMNxd1UF7oEF58gC-eex-0yyzYrnYcxaLlQaV98q3mUU0cI7OUpEDW9Q/AddAzureAccount.png](https://l3oltq-sn3301.files.1drv.com/y2pzikUXZKFXchVQwZT-_pMzIlIGC2xzLI34bkg6wVgdepA64KIGaH-xt6NnZDfJPVqkutiuxdoSvU2S1Gn045_WSw0-cBuBQeMNxd1UF7oEF58gC-eex-0yyzYrnYcxaLlQaV98q3mUU0cI7OUpEDW9Q/AddAzureAccount.png)

## Delete-AzureAllVMDataDisks.ps1

This comes is very useful if your testing and want to wipe out all the data disks associated with a VM.  These disks can all still be attached to the VM as well, this doesn't require detaching the disks before running the script. This script can take a while to run depending on how many drives you have. It may even look like it froze on "VERBOSE: HH:MM:SS - Completed Operation: Get Deployment".  Just be patient, it will eventually complete. Removing 32 Premium Disks took me about 40 minutes for the script to run.
	
Updates I want to make:
  - Option to select a singe disk, multiple disks or all disks