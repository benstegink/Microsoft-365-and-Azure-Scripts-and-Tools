Param(
    [Parameter (Mandatory=$false)]
    [String]$company
)

$creds = Get-AutomationPSCredential -Name 'PowerShellAdmin'
Connect-PnPOnline -Url https://intelligink.sharepoint.com/sites/demo
$term = Get-PnPTerm -TermGroup "Clients" -TermSet "Companies" | ? {$_.Name -eq $company}
if($term -eq $null){
    $term = New-PnPTerm -TermGroup "Clients" -TermSet "Companies" -Name $company
    $exists="New"
}
else{
  $exists="Exists" 
}

Return ($exists + "|" + $term.Name + "|" + $term.Id)
