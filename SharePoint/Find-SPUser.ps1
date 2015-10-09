#URL of the web application to search
$url = [string]"http://mywebapp"
#Entire or part of AD Useranme to find
$username = "myusername"
    

$webs = Get-SPWebApplication $url | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
foreach($web in $webs){
    #Write-Host "Checking" $web.Url "for permissions"
    $perms = $web.Permissions
    foreach($perm in $perms){
        if($perm.Member.Users -eq $null){
            if($perm.Member.UserLogin -match $username){
                Write-Host "Site" $web.Url "contains the user" $username -ForegroundColor Red
                Write-Host "Permissions Given Directly to user" $perm.Member.UserLogin -ForegroundColor Red
            }
        }
        else{
            $users = $perm.Member.Users
            foreach($user in $users){
                if($user.UserLogin -match $username){
                    Write-Host "Site" $web.Url "contains the user" $username -ForegroundColor Green
                    Write-Host "Permission Given via Group" $perm.Member "to user" $user.UserLogin -ForegroundColor Green
                }
            }
        }
    }
}