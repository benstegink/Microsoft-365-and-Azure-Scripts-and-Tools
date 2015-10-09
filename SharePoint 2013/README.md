# SharePoint 2013 Script Index

## InstallSP2013CU.ps1
A slightly modified version of [this script](http://blogs.msdn.com/b/russmax/archive/2013/04/01/why-sharepoint-2013-cumulative-update-takes-5-hours-to-install.aspx) that allows you to pass in the path to the .exe

### Updates
2015-09-21
	- Included Changes from the latest update to the script here: [http://blogs.msdn.com/b/russmax/archive/2013/04/01/why-sharepoint-2013-cumulative-update-takes-5-hours-to-install.aspx](http://blogs.msdn.com/b/russmax/archive/2013/04/01/why-sharepoint-2013-cumulative-update-takes-5-hours-to-install.aspx)
	- Added a Pause function before starting all the services back up.  This enables you to wait to resume starting services until the CU has been installed on all servers.  This prevensts any issues with the scripts stopping/pausing/starting and servers in a multi server farm.
	- Added passive back in, but as a paramter to the function.  Passive is $false by default.