Param(
    [Parameter (Mandatory=$false)]
    [String] $term,
    [Parameter (Mandatory=$true)]
    [Int] $itemID
)
$term
$itemID
$creds = Get-AutomationPSCredential -Name 'SPO'
Connect-PnPOnline -Url https://navuba.sharepoint.com/clients/ -credentials $creds

Write-Output "Connected"
$index = $term.IndexOf("|")
$term = $term.Substring($index+1,$term.Length-$index-1)
$term = $term.Substring(0,36)
$term
$values = @{"Company-Metadata"=$term}
$values
$item = Set-PnPListItem -List "ClientList" -Identity $itemID -Values $values
$item