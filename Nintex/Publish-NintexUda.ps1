function Publish-NintexUda(){
    <#
    .SYNOPSIS
       Publishes a Nintex Workflow UDA (User Defined Action), keeping it's original GUID intact!
    .DESCRIPTION
       Because this approach retains GUIDs, you should avoid deploying the same UDA multiple times
       in an environment. If you want to reuse your UDA in a broader scope that where it is defined,
       you should promote it to a higher level rather than duplicating it.
       This script is designed for moving UDAs between farms.
    .PARAMETER <Scope>
       Mandatory - where the UDA is defined. Must be one of: Farm, SiteCollection, Web
    .PARAMETER <Url>
       Mandatory - the URL of the Site. Note that even for a Farm UDA you need to specify the URL of a valid Web for the publishing process to work.  
    .PARAMETER <UdaFilePath>
       Mandatory - the full Path to the .uda file.
    .PARAMETER <ChangeComments>
       Optional - but allows comments to be added to the publish process.
    .PARAMETER <Publish>
       Optional - deafult value is $true. Using $false will allow it to be imported without publishing.
    .EXAMPLE
       #Here's an example that publishes a Farm level UDA:
       .\Publish-NintexUda.ps1 `
            -Scope "Farm" `
            -Url "http://myfarm/sites/myweb" `
            -UdaFilePath "C:\ExampleUda.uda" `
    #>

    Param(
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Scope,
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $Url,
        [Parameter(Mandatory = $true, Position = 3)]
        [string] $UdaFilePath,
        [Parameter(Mandatory = $false, Position = 4)]
        [string] $ChangeComments = "",
        [Parameter(Mandatory = $false, Position = 5)]
        [bool] $Publish = $true
        )

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SharePoint') | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('Nintex.Workflow') | Out-Null

    function global:ImportNintexWorkflowUDA($filePath, $web, $publish, $configScope, $publishScope, $comments)
    {   
        $fs = New-Object System.IO.FileStream($filePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $ms = New-Object System.IO.MemoryStream
        # This only works for .NET 4 and above, so it won't work in SP 2010
        # $fs.CopyTo($ms)
    
        # Here's the more compatible (and ugly) alternative
        $buffer = New-Object Byte[] 4096
        $read = $fs.Read($buffer, 0, $buffer.Length)
        while ($read -gt 0)
        {
            $ms.Write($buffer, 0, $read)
            $read = $fs.Read($buffer, 0, $buffer.Length)
        }

    
        $fs.Close()
        $fs.Dispose()   
        $uda = [Nintex.Workflow.UserDefinedActions.UserDefinedAction]::Import($web, $ms, $configScope)
        $uda.Update($web, $publish, $publishScope, $comments)
        $ms.Close()
        $ms.Dispose()
    }

    $ArgsValid = $true

    if ($Scope -ne "Farm" -and $Scope -ne "SiteCollection" -and $Scope -ne "Web")
    {
        Write-Host "Error - Scope parameter must be one of: Farm, SiteCollection, Web" -ForegroundColor Red
        $ArgsValid = $false
    }

    $configScope = $null
    $publishScope = $null

    if ($Scope -eq "Farm")
    {
        $configScope = [Nintex.Workflow.ConfigurationScope]::Farm
        $publishScope = [Nintex.Workflow.Publishing.Scope]::Farm
    }
    if ($Scope -eq "SiteCollection")
    {
        $configScope = [Nintex.Workflow.ConfigurationScope]::Site
        $publishScope = [Nintex.Workflow.Publishing.Scope]::SiteCollection
    }
    if ($Scope -eq "Web")
    {
        $configScope = [Nintex.Workflow.ConfigurationScope]::Web
        $publishScope = [Nintex.Workflow.Publishing.Scope]::Web
    }

    if ($ArgsValid)
    {       
        $web = $null
        $web = Get-SPWeb $Url
    
        if ($web -ne $null)
        {
            Write-Host ("Attempting to publish UDA... ") -NoNewline 
            ImportNintexWorkflowUDA $UdaFilePath $web $Publish $configScope $publishScope $ChangeComments
            Write-Host "done"
            $web.Dispose()
        }   
    }
}

