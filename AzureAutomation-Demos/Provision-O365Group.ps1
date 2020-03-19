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

$UserCredential = Get-AutomationPSCredential -Name 'PowerShellAdmin'
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global

$username = $UserCredential.UserName
$secret = Get-AutomationVariable -Name 'ClientSecret'

Connect-PnPOnline -AppId db22d1ee-2d8f-4368-8b53-291cd317477b -AppSecret $secret -AADDomain 'intelligink.onmicrosoft.com'

if($createTeam -eq "False"){
    Connect-PnPOnline -AppId db22d1ee-2d8f-4368-8b53-291cd317477b -AppSecret $secret -AADDomain 'intelligink.onmicrosoft.com'
    #If($friendlyAlias -eq ""){
        New-PnPUnifiedGroup -DisplayName $groupDisplayName -Description $groupDisplayName -Owners $groupOnwer -MailNickname $groupAlias
    #}
    #else{
    #    New-PnPUnifiedGroup -DisplayName $groupDisplayName -Description $groupDisplayName -Owners $groupOnwer -MailNickname $friendlyAlias
    #}
}
else{
    Connect-MicrosoftTeams -Credential $UserCredential
    $groupId = New-Team -DisplayName $groupDisplayName -MailNickname $groupAlias -Visibility $groupAccessType
}

while($group -eq $null){
   $group = Get-PnPUnifiedGroup -Identity $groupDisplayName -ErrorAction SilentlyContinue

    Write-Output "Waiting for Group to Create"
    Start-Sleep -Seconds 60
}

if($groupAccessType -eq "Private"){
    Set-UnifiedGroup -Identity $groupDisplayName -AccessType $groupAccessType
}

Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $creator -LinkType Members
Start-Sleep -Seconds 20
Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $creator -LinkType Owners

Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupOwner -LinkType Members
Start-Sleep -Seconds 20
Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupOwner -LinkType Owners
Remove-UnifiedGroupLinks -Identity $groupDisplayName -Links $username -LinkType Owners -Confirm:$false
Remove-UnifiedGroupLinks -Identity $groupDisplayName -Links $username -LinkType Members -Confirm:$false

if($groupSecondaryOwner -ne $null -and $groupSecondaryOwner -ne ""){
    Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupSecondaryOwner -LinkType Members
    Start-Sleep -Seconds 20
    Add-UnifiedGroupLinks -Identity $groupDisplayName -Links $groupSecondaryOwner -LinkType Owners
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