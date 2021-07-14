#Copy SharePoint Multivalue Lookup Field values between lists
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

# NEED TO VERIFY ALL OF THIS FOR SPO 

$sourceLookupFieldValues = $srcItem[$srcFieldName] #  

# this should be empty but we could check
$destLookupFieldValues = $destItem[$destFieldName] # 

$count = $destLookupFieldValues.Count
# get rid of any current ones
$destLookupFieldValues.RemoveRange(0,$count)

foreach ($sourceLookupFieldValue in $sourceLookupFieldValues)
{  

    # get the current values 
    $srcId = $sourceLookupFieldValue.LookupId;
    $srcValue = $sourceLookupFieldValue.LookupValue;

    Write-host -fore DarkYellow "Lookup Value: " $srcValue " Id: " $srcId  

    # set the corresponding value in new lookup column
    # 
    # add another lookup value since this is multi select.
    $destLookupFieldValues.Add($sourceLookupFieldValue)

}

$destItem[$destLookupFieldDisplayName] =  $destLookupFieldValues

$destItem.Update()

$destList.Update();    