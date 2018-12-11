# Original Script downloaded from https://www.dropbox.com/s/h3j93dl9y5s0g43/TerminatedUserV1.3.ps1?dl=0
# Script was originally found here: https://amp.reddit.com/r/sysadmin/comments/73tt33/by_request_terminated_user_script_365/
# I have not had a chance to run/test the script yet personally, so use at your own risk
# I'll update this as soon as I've had a chance to test it and look through the entire script

$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Please enter in your Domain Admin credentials.  Please remember it should be in the form of DOMAIN\username. The second & third prompt for your credentials, it will be for Office365. At that time, please use  username@fqdn.com",0,"Credentials Needed!",0x0)	
$creds = Get-Credential
 $PSDefaultParameterValues = @{"*-AD*:Credential"=$creds}

#CREATES AN EXCHANGE ONLINE SESSION
$UserCredential = Get-Credential
$ExchangeSession =  New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

#IMPORT SESSION COMMANDS
Import-PsSession $ExchangeSession  -AllowClobber
connect-MsolService

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 
	
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Terminated Employee Process Form"
$objForm.Size = New-Object System.Drawing.Size(500,400) 
$objForm.StartPosition = "CenterScreen"
$objForm.MaximizeBox = $False


$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$userinput=$UserTextBox.Text;$forwardemail=$ForwardingTextBox.Text;$ticketnumber=$TicketTextBox.Text;$disableuser=$DisableUserCheckbox.Checked;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$Font = New-Object System.Drawing.Font("Verdana",8,[System.Drawing.FontStyle]::Bold) 
#$objForm.Font = $Font 
#VERSION NUMBER
$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Location = New-Object System.Drawing.Size(450,10) 
$VersionLabel.Size = New-Object System.Drawing.Size(120,20) 
$VersionLabel.Font = $Font 
$VersionLabel.Text = "V1.3"
$objForm.Controls.Add($VersionLabel) 

#OK AND CANCEL BUTTONS
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,320)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$userinput=$UserTextBox.Text;$ticketnumber=$TicketTextBox.Text;$forwardemail=$ForwardingTextBox.Text;$disableuser=$DisableUserCheckbox.Checked;$objForm.Close()})
$objForm.Controls.Add($OKButton)


#USERNAME LABEL
$UserLabel = New-Object System.Windows.Forms.Label
$UserLabel.Location = New-Object System.Drawing.Size(10,20) 
$UserLabel.Size = New-Object System.Drawing.Size(280,20) 
$UserLabel.Text = "Username of Terminated Employee"
$objForm.Controls.Add($UserLabel) 
#USERNAME TEXT BOX
$UserTextBox = New-Object System.Windows.Forms.TextBox 
$UserTextBox.Location = New-Object System.Drawing.Size(10,40) 
$UserTextBox.Size = New-Object System.Drawing.Size(180,20) 
$objForm.Controls.Add($UserTextBox) 

#DISABLE USER CHECKBOX CONTROL
$DisableUserCheckbox = New-Object System.Windows.Forms.Checkbox 
$DisableUserCheckbox.Location = New-Object System.Drawing.Size(220,30) 
$DisableUserCheckbox.Size = New-Object System.Drawing.Size(120,40)
$DisableUserCheckbox.Text = "Disable The User?"
$objForm.Controls.Add($DisableUserCheckbox)

#FORWARD EMAIL LABEL
$FowardEmailLabel = New-Object System.Windows.Forms.Label
$FowardEmailLabel.Location = New-Object System.Drawing.Size(10,80) 
$FowardEmailLabel.Size = New-Object System.Drawing.Size(280,20)
$FowardEmailLabel.Text = "Forward Email? If Yes, Type In Email Address"
$objForm.Controls.Add($FowardEmailLabel)

#FORWARD EMAIL TEXT BOX
$ForwardingTextBox = New-Object System.Windows.Forms.TextBox 
$ForwardingTextBox.Location = New-Object System.Drawing.Size(10,100) 
$ForwardingTextBox.Size = New-Object System.Drawing.Size(180,40) 
$objForm.Controls.Add($ForwardingTextBox) 

#ENTER TICKET NUMBER TEXT LABEL
$TicketLabel = New-Object System.Windows.Forms.Label
$TicketLabel.Location = New-Object System.Drawing.Size(10,150) 
$TicketLabel.Size = New-Object System.Drawing.Size(80,20)
$TicketLabel.Text = "Ticket Number"
$objForm.Controls.Add($TicketLabel)

$TicketTextBox = New-Object System.Windows.Forms.TextBox 
$TicketTextBox.Location = New-Object System.Drawing.Size(10,170) 
$TicketTextBox.Size = New-Object System.Drawing.Size(40,250) 
$objForm.Controls.Add($TicketTextBox) 


#CANCEL BUTTONS
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(350,320)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close(); $cancel = $true})
$objForm.Controls.Add($CancelButton)


$objForm.Topmost = $True
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()
if ($cancel) {return}
#$OKButton.Add_Click({$userinput=$UserTextBox.Text;$ticketnumber=$TicketTextBox.Text;$forwardemail=$ForwardingTextBox.Text;$disableuser=$DisableUserCheckbox.Checked;$objForm.Close()})
#$CancelButton.Add_Click({$objForm.Close()})

#COMMON GLOBAL VARIABLES
$disableusercheckbox=$DisableUserCheckbox.Checked
$userinput=$UserTextBox.Text
$forwardemail=$ForwardingTextBox.Text
$ticketnumber=$TicketTextBox.Text

$Month = Get-Date -format MM
$Day = Get-Date -format dd
$Year = Get-Date -format yyyy




If ($OKButton.Add_Click) {
    
    
########
#ACTIVE DIRECTORY ACTIONS
#########

#DISABLE THE USER
If ($disableusercheckbox -eq $true)
{
  Disable-ADAccount -Identity $userinput
  $disabled = $userinput + " has been disabled"
} else { 
	$notdisabled = $userinput + " has not been disabled at this time" 
}

#GETS ALL GROUPS USER WAS PART OF BEFORE BLOWING THEM OUT
    $User = $userinput
    $List=@()
    $Groups = Get-ADUser -Identity $User -Properties * | select -ExpandProperty memberof
    foreach($i in $Groups){
    $i = ($i -split ',')[0]
    $List += "`r`n" + ($i -creplace 'CN=|}','')
    }
    
#BLOW OUT GROUPS OF USER EXCEPT DOMAIN USERS
(get-aduser $userinput -properties memberof).memberof|remove-adgroupmember -member $userinput -Confirm:$False
	
	
#ADDS THE GROUP NO GFI ARCHIVE TO THE DISABLED USER	
Add-AdGroupMember -identity "NO GFI Archive" -Member $userinput

#SETS THE USERS TITLE,COMPANY/MANAGER TO DISABLED
set-aduser -identity $userinput -title "COMPANY NAME - Disabled $Month$Day$Year"
set-aduser -identity $userinput -company $null
set-aduser -identity $userinput -manager $null
set-aduser -identity $userinput -department $null

#CHANGES THE USERS PASSWORD
$newpwd = ConvertTo-SecureString -String "G00dBye@1234" -AsPlainText –Force
Set-ADAccountPassword $userinput –NewPassword $newpwd -Reset

#MOVES THE USER TO DISABLED USERS
Get-ADUser -Filter { samAccountName -like $userinput } | Move-ADObject –TargetPath "OU=Disabled Users,DC=DOMAIN,DC=net"


#HIDES USER FROM GLOBAL ADDRESS BOOK
$user = Get-ADUser $userinput –properties *
$user.msExchHideFromAddressLists = "True"
Set-ADUser –instance $user
#Set-Mailbox $userinput -HiddenFromAddressListsEnabled $true


Start-Sleep -s 3


########
#OFFICE 365 ACTIONS
#########

#REMOVES THE USER LICENSE
Set-MsolUserLicense -UserPrincipalName $userinput@yourdomain.com -RemoveLicenses "COMPANYNAME:ENTERPRISEPACKWITHOUTPROPLUS"    

#CONVERTS THE USERMAILBOX TO A SHARED MAILBOX
Set-Mailbox $userinput -Type shared

#SETS THE FORWARD
If ($forwardemail){
$forwarded = $userinput + " email is now being forwarded to " + $forwardemail
Set-Mailbox $userinput -ForwardingAddress $forwardemail -DeliverToMailboxAndForward $true 
} else { $notforwarded = "No email forwards at this time"}

#REMOVES THE SESSION
Remove-PSsession $ExchangeSession 


Start-Sleep -s 2


#STARTS UP OUTLOOK TO FIRE OFF EMAIL
Start-Process Outlook
$olAppointmentItem = 1 
$o = new-object -com outlook.application
$ol = New-Object -ComObject Outlook.Application
$meeting = $ol.CreateItem('olAppointmentItem')

#$File = "\\icrdc05\IT$\Scripts\Office365\90daycleanup.ps1"
$meeting.Attachments.Add($File)

$meeting.Subject = "Revisit Ticket $ticketnumber - $userinput"
$meeting.Body = @"
This reminder is for 90 days out.

Meeting marker if you choose to put on your calendar then please accept.

- IT team Member:  Please revisit this ticket to validate with stakeholder if  email forwards need to continue.  ( $userinput -> $forwarded$notforwarded ).

 $userinput Account should already be disabled. Please move to AD OU  “To Be Deleted”

"@

$meeting.Location = ''
$meeting.ReminderSet = $true
$meeting.Importance = 1
$meeting.MeetingStatus = [Microsoft.Office.Interop.Outlook.OlMeetingStatus]::olMeeting
$meeting.Recipients.Add('type_your_email_here')
$meeting.Recipients.Add('type_your_email_here')
$meeting.ReminderMinutesBeforeStart = 15
$meeting.Start = [datetime]::Today.Adddays(90)
$meeting.Duration = 30
$meeting.Send()


Start-Sleep -s 2


$Mail = $ol.CreateItem(0)
$Mail.To = "helpdesk email address goes here"
$Mail.Subject = "Ticket:$ticketnumber Action:TechUpdate Hidden:NO Status: EmailClient:YES "
$Mail.Body = @"
Internal Network Changes:

$disabled$notdisabled

Password has been set to G00dBye@1234

Changed Job Title to:  ICR - Disabled $Month$Day$Year

Department, Company & Manager have all been Cleared

Removed from the following Groups in AD:
$List

Added No GFI Archive

Moved to Disabled Users in AD


Office 365 Changes:

Converted $userinput to a Shared Mailbox
Removed Office 365 License
Hidden from Global Address Book
$forwarded$notforwarded

90 day Status Quo appt has been sent out
"@
$Mail.Send()


}

