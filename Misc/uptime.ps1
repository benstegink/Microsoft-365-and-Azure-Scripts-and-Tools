$wmi = Get-WmiObject -Class Win32_OperatingSystem
$currentTime = $wmi.ConvertToDateTime($wmi.LocalDateTime)
$lastBoot = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
$uptime = $currentTime - $lastBoot
Write-Host "Uptime:"$uptime