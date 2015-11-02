#Script Source
#http://get-spscripts.com/2010/08/check-size-of-sharepoint-2010-sites.html

#***************Reporting Functions***************

#Get the Site of a Web and all Sub Webs
#SharePoint 2010 - Verified
#SharePoint 2013 - Untested
#Office 365 - Dosn't Work
function GetWebSizes ($StartWeb)
{
    $web = Get-SPWeb $StartWeb
    [long]$total = 0
    $total += GetWebSize -Web $web
    $total += GetSubWebSizes -Web $web
    $totalInMb = ($total/1024)/1024
    $totalInMb = "{0:N2}" -f $totalInMb
    $totalInGb = (($total/1024)/1024)/1024
    $totalInGb = "{0:N2}" -f $totalInGb
    write-host "Total size of all sites below" $StartWeb "is" $total "Bytes,"
    write-host "which is" $totalInMb "MB or" $totalInGb "GB"
    $web.Dispose()
}

#Get the Site of a Single Web
#SharePoint 2010 - Verified
#SharePoint 2013 - Untested
#Office 365 - Dosn't Work
function GetWebSize ($Web)
{
    [long]$subtotal = 0
    foreach ($folder in $Web.Folders)
    {
        $subtotal += GetFolderSize -Folder $folder
    }
    write-host "Site" $Web.Title "is" $subtotal "KB"
    return $subtotal
}

#Get the Site of all Sub Webs
#SharePoint 2010 - Verified
#SharePoint 2013 - Untested
#Office 365 - Dosn't Work
function GetSubWebSizes ($Web)
{
    [long]$subtotal = 0
    foreach ($subweb in $Web.GetSubwebsForCurrentUser())
    {
        [long]$webtotal = 0
        foreach ($folder in $subweb.Folders)
        {
            $webtotal += GetFolderSize -Folder $folder
        }
        write-host "Site" $subweb.Title "is" $webtotal "Bytes"
        $subtotal += $webtotal
        $subtotal += GetSubWebSizes -Web $subweb
    }
    return $subtotal
}

#Get the Site of a Folder
#SharePoint 2010 - Verified
#SharePoint 2013 - Untested
#Office 365 - Dosn't Work
function GetFolderSize ($Folder)
{
    [long]$folderSize = 0  
    foreach ($file in $Folder.Files)
    {
        $folderSize += $file.Length;
    }
    foreach ($fd in $Folder.SubFolders)
    {
        $folderSize += GetFolderSize -Folder $fd
    }
    return $folderSize
}

#***************End Reporting Functions***************