#***** Required modules *****
#MicrosoftTeams
#PnPPowerShell Online

#***** App Permissions for using App ID and Secret *****
#  Group.ReadWrite.All
#  User.Read
#  User.Read.All

#***** User App ID and Certificate for Teams
# Run Create-NewCertificate.ps1
# Export ad a .CER
# Upload it to the app above and use the thumbprint with the Connect-MicrosoftTeams

#***** Parameter descriptions *****
#  $groupDisplayName
#  $groupAlias
#  $groupAccessType
#  $groupOwner
#  $

Param(
    [Parameter (Mandatory=$false)]
    [String] $groupDisplayName,
    [Parameter (Mandatory=$false)]
    [String] $groupAlias,
    [Parameter (Mandatory=$false)]
    [String] $groupAccessType,
    [Parameter (Mandatory=$false)]
    [String] $groupOwner,
    [Parameter (Mandatory=$false)]
    [String] $groupSecondaryOwner,
    [Parameter (Mandatory=$false)]
    [String] $createTeam,
    [Parameter (Mandatory=$false)]
    [String] $creator,
    [Parameter (Mandatory=$false)]
    [String] $friendlyAlias,
    [Parameter (Mandatory=$true)]
    [String] $addressbookvisible,
    [Parameter (Mandatory=$true)]
    [String] $externalemail
)

$Tenant = "Intelligink"
$AADDomain = $Tenant + ".com"
$SMTPDomain = "@" + $AADDomain
$SMTPonMSDomain = "@" + $Tenant + ".onmicrosoft.com"
$group = $null

#***** Used for setting Exchange properties for friendly alias
$UserCredential = Get-AutomationPSCredential -Name 'PowerShellAdmin'
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global

$username = $UserCredential.UserName
$secret = Get-AutomationVariable -Name 'ClientSecret'

Connect-PnPOnline -AppId db22d1ee-2d8f-4368-8b53-291cd317477b -AppSecret $secret -AADDomain 'intelligink.onmicrosoft.com'

if($createTeam -eq "False"){
    New-PnPUnifiedGroup -DisplayName $groupDisplayName -Description $groupDisplayName -Owners $groupOwner -MailNickname $groupAlias
}
else{
    #***** If you want to use the Teams Module *****
    Connect-MicrosoftTeams -Credential $UserCredential
    $groupId = New-Team -DisplayName $groupDisplayName -MailNickname $groupAlias -Visibility $groupAccessType
    #***** If you want to do everything with the PnP SharePoint Module
    #Start-Sleep -Seconds 1200
    #Set-PnPUnifiedGroup -Identity $group -CreateTeam
}

while($group -eq $null){
    $group = Get-PnPUnifiedGroup -Identity $groupDisplayName -ErrorAction SilentlyContinue
    Write-Output "Waiting for Group to Create"
    Start-Sleep -Seconds 60
}

if($groupAccessType -eq "Private"){
    Set-PnPUnifiedGroup -Identity $group -IsPrivate
    #Set-UnifiedGroup -Identity $groupDisplayName -AccessType $groupAccessType
}

Set-PnPUnifiedGroup -Identity $group -Members ($creator,$groupOwner)
#Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $creator -LinkType Members
Start-Sleep -Seconds 20
Set-PnPUnifiedGroup -Identity $group -Owners ($creator,$groupOwner)
#Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $creator -LinkType Owners


#Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupOwner -LinkType Members
#Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupOwner -LinkType Owners
#Remove the user added view the Connection - not sure I still need this
#Remove-UnifiedGroupLinks -Identity $groupDisplayName -Links $username -LinkType Owners -Confirm:$false
#Remove-UnifiedGroupLinks -Identity $groupDisplayName -Links $username -LinkType Members -Confirm:$false

if($groupSecondaryOwner -ne $null -and $groupSecondaryOwner -ne ""){
    Set-PnPUnifiedGroup -Identity $group -Members @($creator,$groupOwner,$groupSecondaryOwner)
    #Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupSecondaryOwner -LinkType Members
    Start-Sleep -Seconds 20
    Set-PnPUnifiedGroup -Identity $group -Owners @($creator,$groupOwner,$groupSecondaryOwner)
    #Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupSecondaryOwner -LinkType Owners
}

if($friendlyAlias -ne ""){
    $rec = Get-Recipient $friendlyAlias -ErrorAction SilentlyContinue
    if($rec -eq $null){
        Set-UnifiedGroup -Identity $groupDisplayName -Alias $friendlyAlias
        $intelliginkEmail = ("smtp:" + $friendlyAlias + "@intelligink.com")
        $intelliginkMSEmail = ("smtp:" + $friendlyAlias + "@intelligink.onmicrosoft.com")
        $primarySMTP = ($friendlyAlias + "@intelligink.onmicrosoft.com")
        Write-Output "New Email Addresses: $intelliginkEmail, $intelliginkMSEmail with the primary address of $primarySMTP"
        Set-UnifiedGroup -Identity $groupDisplayName -EmailAddresses @{Add=$intelliginkEmail,$intelliginkMSEmail}
        Set-UnifiedGroup -Identity $groupDisplayName -PrimarySmtpAddress $primarySMTP
    }
    else{
        Write-Output "the alias $friendlyAlias already exists"
    }
}

if($externalemail){
    Set-UnifiedGroup -Identity $friendlyAlias -RequireSenderAuthenticationEnabled $false
}
else{
    Set-UnifiedGroup -Identity $friendlyAlias -RequireSenderAuthenticationEnabled $true
}

if($addressbookvisible){
    Set-UnifiedGroup -Identity $friendlyAlias -HiddenFromAddressListsEnabled $false
}
else{
    Set-UnifiedGroup -Identity $friendlyAlias -HiddenFromAddressListsEnabled $true
}