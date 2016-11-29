$PortNumber = 2016
$AuthProvider = "NTLM"

Install-SPHelpCollection -All
Initialize-SPResourceSecurity
Install-SPService
Install-SPFeature -AllExistingFeatures
New-SPCentralAdministration -Port $PortNumber -WindowsAuthProvider $AuthProvider
Install-SPApplicationContent