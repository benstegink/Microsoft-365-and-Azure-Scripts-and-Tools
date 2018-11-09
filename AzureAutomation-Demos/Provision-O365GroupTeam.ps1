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
    [String] $creator
)

$UserCredential = Get-AutomationPSCredential -Name 'Provisioning'
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $Session -AllowClobber -DisableNameChecking) -Global

$username = $UserCredential.UserName

if($createTeam -eq "False"){
   
    $password = $UserCredential.GetNetworkCredential().Password
    $client_id = "";
    $client_secret = "";
    $tenant_id = "";
    $resource = "https://graph.microsoft.com";
    # grant_type = password
    $authority = "https://login.microsoftonline.com/$tenant_id";
    $tokenEndpointUri = "$authority/oauth2/token"
    $content = "grant_type=password&username=$username&password=$password&client_id=$client_id&client_secret=$client_secret&resource=$resource";
    $response = Invoke-WebRequest -Uri $tokenEndpointUri -Body $content -Method Post -UseBasicParsing
    $responseBody = $response.Content | ConvertFrom-JSON
    #$responseBody
    #$responseBody.access_token


    $access_token = $responseBody.access_token

    # GET https://graph.microsoft.io/en-us/docs/api-reference/v1.0/api/group_list
    $body = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups" -Headers @{"Authorization" = "Bearer $access_token"}
    #$body | ConvertTo-JSON

    # POST - this creates groups https://graph.microsoft.io/en-us/docs/api-reference/v1.0/api/group_post_groups
    $body = @{"displayName"=$groupDisplayName; "mailEnabled"=$false; "groupTypes"=@("Unified"); "securityEnabled"=$false; "mailNickname"=$groupAlias;} | ConvertTo-Json 
    $body = Invoke-RestMethod `
        -Uri "https://graph.microsoft.com/v1.0/groups" `
        -Headers @{"Authorization" = "Bearer $access_token"} `
        -Body $body `
        -ContentType "application/json" `
        -Method POST
    #$body | ConvertTo-JSON

    while($group -eq $null){
        $group = Get-UnifiedGroup -Identity $groupAlias -ErrorAction SilentlyContinue

        Start-Sleep -Seconds 60
        Write-Output "Waiting for Group to Create"
    }
}
else{
    Connect-MicrosoftTeams -Credential $UserCredential
    $groupId = New-Team -DisplayName $groupDisplayName -Alias $groupAlias
}

if($groupAccessType -eq "Private"){
    Set-UnifiedGroup -Identity $groupAlias -AccessType $groupAccessType
}

Add-UnifiedGroupLinks -Identity $groupAlias -Links $creator -LinkType Members
Add-UnifiedGroupLinks -Identity $groupAlias -Links $creator -LinkType Owners

Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupOwner -LinkType Members
Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupOwner -LinkType Owners
Remove-UnifiedGroupLinks -Identity $groupAlias -Links $username -LinkType Owners -Confirm:$false
Remove-UnifiedGroupLinks -Identity $groupAlias -Links $username -LinkType Members -Confirm:$false

if($groupSecondaryOwner -ne $null){
    Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupSecondaryOwner -LinkType Members
    Add-UnifiedGroupLinks -Identity $groupAlias -Links $groupSecondaryOwner -LinkType Owners
}
