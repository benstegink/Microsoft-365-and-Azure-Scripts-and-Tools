$cred = Get-AutomationPSCredential -Name "PowerShell"
$backupcred = $cred
Connect-AzureAD -Credential $cred
$cred = Get-AutomationPSCredential -Name "PowerShell"
Connect-PnPOnline https://intelligink-admin.sharepoint.com -Credential $backupcred


$users = Get-AzureADUser -All $true
Write-Host $users.Count
foreach($user in $users){
    $upn = $user.UserPrincipalName
    Write-Output "Updating User Profile Information for $upn"
    if($user.City -ne $null){
        Write-Output "Updating City for $upn"
        Set-PnPUserProfileProperty -Account $upn -PropertyName "City" -Value $user.City
    }
    if($user.State -ne $null){
        Write-Output "Updating State for $upn"
        Set-PnPUserProfileProperty -Account $upn -PropertyName "State" -Value $user.State
    }
    if($user.StreetAddress -ne $null){
        Write-Output "Updating Street Address for $upn"
        Set-PnPUserProfileProperty -Account $upn -PropertyName "StreetAddress" -Value $user.StreetAddress
    }
}