function{}
<#  
 .SYNOPSIS 
  Configures App Full Trust for running provider hosted apps on SharePoint 2013
   
 .DESCRIPTION 
  A more detailed description of what this function does
    
 .PARAMETER publicCertPath
  This is the path to the .cer certificate that will be used for validation between the app and SharePoint
 
 .PARAMETER siteUrl
  The Site URL for the root site collection where you want to run the application

 .PARAMETER Name
  The Name that will be used for the TrustedRootAuthority, TrustedSecurityTokenIssuer and SPAppPrinciple
    
 .EXAMPLE 
 
 .NOTES
 Author: Ben Stegink
 Last Modifed By: Ben Stegink                                      
 Date Created: Yesterday                           
 Last Modified: Today
 This Script originated from Jeremy Thake's post here - http://www.jeremythake.com/2013/12/troubleshooting-sharepoint-2013-provider-hosted-apps-on-premises/
 The post is also a great reference for troubleshooting issues with provider hosted apps.
   
#>

[CmdletBinding()] 
Param(
    [parameter(Mandatory=$True,Position=1)][string]$publicCertPath,
    [parameter(Mandatory=$True,Position=2)][string]$siteUrl,
    [parameter(Mandatory=$True,Position=3)][string]$Name
    )

    if((Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null)
    {
        Add-PsSnapin Microsoft.SharePoint.PowerShell
    }
    $issuerID = [System.Guid]::NewGuid().ToString()
    $publicCertPath = $publicCertPath
    $siteUrl = $siteUrl
    $web = Get-SPWeb $siteUrl
    $certificate = Get-PfxCertificate $publicCertPath
    $realm = Get-SPAuthenticationRealm -ServiceContext $web.Site
    $fullAppIdentifier = $issuerId + '@' + $realm
    New-SPTrustedRootAuthority -Name $Name -Certificate $certificate
    New-SPTrustedSecurityTokenIssuer -Name $Name -Certificate $certificate -RegisteredIssuerName $fullAppIdentifier
    Register-SPAppPrincipal -NameIdentifier $fullAppIdentifier -Site $web -DisplayName $Name
    iisreset
    return $issuerID
}