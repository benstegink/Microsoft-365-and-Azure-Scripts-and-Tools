Param(
    [Parameter (Mandatory=$true)]
    [String] $username,
    [Parameter (Mandatory=$false)]
    [String] $usageLocation = "US"
)

$accountSKUID = "aptar:ENTERPRISEPACK"
$cred = Get-AutomationPSCredential -Name 'Provisioning'
Connect-AzureAD -Credential $cred
$cred = Get-AutomationPSCredential -Name 'Provisioning'
Connect-PnPOnline -Url https://aptar.sharepoint.com -Credentials $cred
$filter = "UserPrincipalName eq '$username'"

#Assign Licenses to all users
#foreach($user in $users){
    $o365user = Get-AzureADUser -All $true -Filter $filter -ErrorAction SilentlyContinue
    if($o365user -ne $null){
        Connect-PnPOnline -Url https://aptar.sharepoint.com -Credentials $cred
        if($o365user.AccountEnabled -eq $false)
        {
            Write-Output "Signin Not Allowed for" $username
        }
        else{
            $AssignedLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            $E3 = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $Sku = Get-AzureADSubscribedSku | ?{$_.SkuPartNumber -eq "ENTERPRISEPACK"}
            $E3.SkuId = $Sku.SkuId
            $displayName = $o365user.DisplayName
            Write-Output "Assigning SPO License to $displayName"
            $defaultDisabled = @("SWAY","YAMMER_ENTERPRISE","Deskless")
            foreach($servicePlan in $defaultDisabled){
                $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq $servicePlan}).ServicePlanID
            }
            $license = $null
            $license = $o365user.AssignedLicenses | ? {$_.SkuId -eq $Sku.SkuId}
            if($license -eq $null){
                $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq "OFFICESUBSCRIPTION"}).ServicePlanID
                $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq "MCOSTANDARD"}).ServicePlanID
                $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq "EXCHANGE_S_ENTERPRISE"}).ServicePlanID
                $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq "STREAM_O365_E3"}).ServicePlanID
                
                $AssignedLicenses.AddLicenses += $E3
                $AssignedLicenses.RemoveLicenses = @()

                Write-Output $o365user.ObjectId $usageLocation
                Set-AzureADUser -ObjectID $o365user.ObjectId -UsageLocation $usageLocation
                Set-AzureADUserLicense -ObjectID $o365user.ObjectId -AssignedLicenses $AssignedLicenses
            }
            else{
                $license = Get-AzureADUserLicenseDetail -ObjectId $o365user.ObjectId | ? {$_.SkuPartNumber -eq $sku.SkuPartNumber}
                #Exchange
                $exchStatus = $license.ServicePlans | ? {$_.ServicePlanName -eq "EXCHANGE_S_ENTERPRISE"}
                if($exchStatus.ProvisioningStatus -ne "Success"){
                 $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq "EXCHANGE_S_ENTERPRISE"}).ServicePlanID
                }
                #Skype For Biz
                $s4bStatus = $license.ServicePlans | ? {$_.ServicePlan.ServiceName -eq "MCOSTANDARD"}
                if($s4bStatus.ProvisioningStatus -ne "Success"){
                 $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq "MCOSTANDARD"}).ServicePlanID
                }
                #Office Subscription
                $officeStatus = $license.ServicePlans | ? {$_.ServicePlan.ServiceName -eq "OFFICESUBSCRIPTION"}
                if($officeStatus.ProvisioningStatus -ne "Success"){
                 $E3.DisabledPlans += ($sku.ServicePlans | ?{$_.ServicePlanName -eq "OFFICESUBSCRIPTION"}).ServicePlanID
                }

                $AssignedLicenses.AddLicenses += $E3
                $AssignedLicenses.RemoveLicenses = @()
                Write-Output $AssignedLicenses | FL
                Set-AzureADUserLicense -ObjectID $o365user.ObjectId -AssignedLicenses $AssignedLicenses
            }
            Start-Sleep -Seconds 30
            $o365user = Get-AzureADUser -All $true -Filter $filter -ErrorAction SilentlyContinue
            $license = $null
            $license = $o365user.AssignedLicenses | ? {$_.SkuId -eq $Sku.SkuId}
            if($license -ne $null){
                $personalURL = (Get-PnPUserProfileProperty -Account $username).PersonalUrl
                if($personalURL -match "Person.aspx"){
                    $cred = Get-AutomationPSCredential -Name 'Provisioning'
                    Connect-SPOService -Url https://aptar-admin.sharepoint.com -Credential $cred
                    Request-SPOPersonalSite -UserEmails $username -NoWait
                    Write-Output "Provisioning OneDrive for Business..."
                }
                else{
                    Write-Output "OneDrive has already been provisioned for $username"
                }        
            }
            else{
                Write-Output "There was an error assigning licenses for $username"
            }
        }
    }
    else{
        Write-Output $username "could not be found"
    }