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

$UserCredential = Get-AutomationPSCredential -Name 'Provisioning'
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global

$username = $UserCredential.UserName
$secret = Get-AutomationVariable -Name 'ClientSecret'

if($createTeam -eq "False"){
    Connect-PnPOnline -AppId db22d1ee-2d8f-4368-8b53-291cd317477b -AppSecret $secret -AADDomain 'intelligink.onmicrosoft.com'
    If($friendlyAlias -eq ""){
        New-PnPUnifiedGroup -DisplayName $groupDisplayName -Description $groupDisplayName -Owners $groupOnwer -MailNickname $groupAlias
    }
    else{
        New-PnPUnifiedGroup -DisplayName $groupDisplayName -Description $groupDisplayName -Owners $groupOnwer -MailNickname $friendlyAlias
    }
}
else{
    Connect-MicrosoftTeams -Credential $UserCredential
    $groupId = New-Team -DisplayName $groupDisplayName -Alias $groupAlias
}

while($group -eq $null){
    $group = Get-UnifiedGroup -Identity $groupAlias -ErrorAction SilentlyContinue

    Start-Sleep -Seconds 60
    Write-Output "Waiting for Group to Create"
}

if($groupAccessType -eq "Private"){
    Set-UnifiedGroup -Identity $groupAlias -AccessType $groupAccessType
}

Add-UnifiedGroupLinks -Identity $groupAlias -Links $creator -LinkType Members
Start-Sleep -Seconds 20
Add-UnifiedGroupLinks -Identity $groupAlias -Links $creator -LinkType Owners

Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupOwner -LinkType Members
Start-Sleep -Seconds 20
Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupOwner -LinkType Owners
Remove-UnifiedGroupLinks -Identity $groupAlias -Links $username -LinkType Owners -Confirm:$false
Remove-UnifiedGroupLinks -Identity $groupAlias -Links $username -LinkType Members -Confirm:$false

if($groupSecondaryOwner -ne $null -and $groupSecondaryOwner -ne ""){
    Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupSecondaryOwner -LinkType Members
    Start-Sleep -Seconds 20
    Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupSecondaryOwner -LinkType Owners
}

if($friendlyAlias -ne ""){
    $rec = Get-Recipient $friendlyAlias -ErrorAction SilentlyContinue
    if($rec -eq $null){
        Set-UnifiedGroup -Identity $groupAlias -Alias $friendlyAlias
        $aptarEmail = ("smtp:" + $friendlyAlias + "@aptar.com")
        $aptarMSEmail = ("smtp:" + $friendlyAlias + "@aptar.onmicrosoft.com")
        $primarySMTP = ($friendlyAlias + "@aptar.onmicrosoft.com")
        Write-Output "New Email Addresses: $aptarEmail, $aptarMSEmail with the primary address of $primarySMTP"
        Set-UnifiedGroup -Identity $groupDisplayName -EmailAddresses @{Add=$aptarEmail,$aptarMSEmail}
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