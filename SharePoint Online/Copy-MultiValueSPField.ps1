Param(
  [Parameter (Mandatory=$true)]
  [String] $url,
  [Parameter (Mandatory=$true)]
  [String]$srcListName,
  [Parameter (Mandatory=$true)]
  [String]$destListName,
  [Parameter (Mandatory=$true)]
  [Int]$srcItemID,
  [Parameter (Mandatory=$true)]
  [Int]$destItemID,
  [Parameter (Mandatory=$true)]
  [String]$srcFieldName,
  [Parameter (Mandatory=$true)]
  [String]$destFieldName
) 

$cred = Get-AutomationPSCredential -Name 'PowerShellAdmin'
Connect-PnPOnline -Url $url -Credentials $cred
$srcList = Get-PnPList -Identity $srcListName
$destList = Get-PnPList -Identity $destListName
$srcItem = Get-PnPListItem -List $srcList -Id $srcItemId
$destItem = Get-PnPListItem -List $destList -Id $destItemID

$depts = $srcItem.FieldValues[$srcFieldName]
foreach($dept in $depts){
  $arrayDept += @($dept)
}

Set-PnPListItem -List $destList -Identity $destItemId -Values @{$destFieldName = $arrayDept} -SystemUpdate | Out-Null
