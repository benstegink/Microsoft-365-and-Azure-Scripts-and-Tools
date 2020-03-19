Param
(
  [Parameter (Mandatory=$true)]
  [String] $url,
  [Parameter (Mandatory=$true)]
  [String]$listName,
  [Parameter (Mandatory=$true)]
  [Int]$itemID,
  [Parameter (Mandatory=$true)]
  [String]$UserOrGroup,
  [Parameter (Mandatory=$true)]
  [String]$EmailOrGroupName,
  [Parameter (Mandatory=$true)]
  [String]$PermissionLevel
)

$cred = Get-AutomationPSCredential -Name 'SPOnline'
Connect-PnPOnline -Url $url -Credentials $cred

$list = Get-PnPList -Identity $listName
$web = Get-PnPWeb
$item = Get-PnPListItem -List $list -Id $itemID

$uniquePermissions = Get-PnPProperty -ClientObject $item -Property HasUniqueRoleAssignments
#If it applies to all departments, runbook won't even run, filter out/skip runbook via flow
if($uniquePermissions){
    Write-Output "Already has unique permissions"
}
else{
    $item.BreakRoleInheritance($false,$true)
    $item.Update()
    $item.Context.ExecuteQuery()
    Start-Sleep -Seconds 10
}

If($UserOrGroup -eq "User"){
  Set-PnPListItemPermission -List $list -Identity $item.Id -User $EmailOrGroupName -AddRole $PermissionLevel
}
If($UserOrGroup -eq "Group"){
  Set-PnPListItemPermission -List $list -Identity $item.Id -Group $EmailOrGroupName -AddRole $PermissionLevel
}