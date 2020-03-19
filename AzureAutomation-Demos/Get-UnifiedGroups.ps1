$secret = Get-AutomationVariable -Name 'ClientSecret'
Write-Output $secret
Connect-PnPOnline -AppId db22d1ee-2d8f-4368-8b53-291cd317477b -AppSecret $secret -AADDomain 'intelligink.onmicrosoft.com'
Get-PnPUnifiedGroup
#New-PnPUnifiedGroup -DisplayName "Live360 2018c2" -Description "Test for Demo" -Owners "bstegink@intelligink.com" -MailNickname "Live360-2018-2"