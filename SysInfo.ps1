Write-Host "========================================================================================" -ForegroundColor Yellow
Write-Host "                               SYSTEM INFORMATION SUMMARY                               " -ForegroundColor Yellow
Write-Host "========================================================================================" -ForegroundColor Yellow
#"Date`t`t`t: {0}" -f (Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
"{0,-9}: {1}" -f "Date",(Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
"{0,-9}: {1}" -f "Computer",(hostname)
"{0,-9}: {1}" -f "User name",(Get-CimInstance -ClassName Win32_ComputerSystem).UserName
Write-Host "----------------------------------------------------------------------------------------"
""

# computer info
Write-Host "COMPUTER:" -ForegroundColor Cyan
"  {0,-20}: {1}" -f "Model",(Get-CimInstance -ClassName Win32_ComputerSystem).Model

$chassisType = ""
switch ((Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes) {
    3 { $chassisType = 'Desktop' }
    8 { $chassisType = 'Portable'}
    9 { $chassisType = 'Laptop'}
    10 { $chassisType = 'Notebook'}
    13 { $chassisType = 'All in One'}
    14 { $chassisType = 'Sub Notebook'}
    30 { $chassisType = 'Tablet'}
    Default { $chassisType = 'none' }
}
"  {0,-20}: {1}" -f "Chassis type",$chassisType
"  {0,-20}: {1}" -f "Serial Number",(Get-CimInstance -ClassName Win32_SystemEnclosure).SerialNumber
""

# operating system info
Write-Host "OPERATING SYSTEM:" -ForegroundColor Cyan
#"User name`t`t: {0}" -f (whoami)
#"User name`t`t: " -f (whoami) | Write-Host -ForegroundColor Green -NoNewline;"{0}" -f (whoami) | Write-Host
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$os_version = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
"  {0,-20}: {1} {2} ({3})" -f "Name",$os.Caption,$os.OSArchitecture,$os_version.DisplayVersion
"  {0,-20}: {1}.{2}" -f "Version",$os_version.CurrentBuildNumber,$os_version.UBR

#"Operating System`t: {0} {1} ({2})" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption,(Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture,(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
"  {0,-20}: {1}{2}, {3:dd} {3:MMMM} {3:yyy} {3:hh}:{3:mm}:{3:ss} ({4}d {5})" -f "Last bootup time",$os.LastBootUpTime.ToString("dddd").ToUpper()[0],$os.LastBootUpTime.ToString("dddd").Substring(1),$os.LastBootUpTime,((Get-Date)-$os.LastBootUpTime).ToString().Split(".")[0],((Get-Date)-$os.LastBootUpTime).ToString().Split(".")[1]
"  {0,-20}: {1}{2}, {3:dd} {3:MMMM} {3:yyy} {3:hh}:{3:mm}:{3:ss} ({4}d {5})" -f "Installation date",$os.InstallDate.ToString("dddd").ToUpper()[0],$os.InstallDate.ToString("dddd").Substring(1),$os.InstallDate,((Get-Date)-$os.InstallDate).ToString().Split(".")[0],((Get-Date)-$os.InstallDate).ToString().Split(".")[1]
""

# processor info
Write-Host "PROCESSOR:" -ForegroundColor Cyan
$processor = Get-CimInstance -ClassName Win32_Processor
#"Processor`t`t: {0} ({1} Cores)" -f ((Get-CimInstance -ClassName Win32_Processor).Name),(Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
"  {0,-20}: {1} ({2} Cores)" -f "Model",$processor.Name,$processor.NumberOfLogicalProcessors
""

# video card info
# vram not working
Write-Host "VIDEO CARD:" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_VideoController | ForEach-Object {
    #"  {0,-20}: {1,-40} VRAM: {2} GB" -f "Model",$_.Name,[Math]::Round( ($_.AdapterRAM / 1GB), 2)
    "  {0,-20}: {1}" -f "Model",$_.Name
}
#"Graphic card`t`t: {0} | VRAM: {1} GB" -f (Get-CimInstance Win32_VideoController).Name,([Math]::Round((Get-CimInstance Win32_VideoController).AdapterRam / 1GB, 2))
#"Graphic card`t`t: {0}" -f (Get-CimInstance Win32_VideoController).Name
""

# memory info
Write-Host "MEMORY:" -ForegroundColor Cyan
$mem = Get-CimInstance Win32_OperatingSystem
$totalRam = [Math]::Round($mem.TotalVisibleMemorySize / 1MB, 2)
$freeRam = [Math]::Round($mem.FreePhysicalMemory / 1MB, 2)
$usedRam = $totalRam - $freeRam
#"Memory`t`t`t: {0:N2} GB used of {1:N2} GB" -f ([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)-[Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)),([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2))
"  {0,-20}: {1:N2} GB used of {2:N2} GB" -f "Ram",$usedRam,$totalRam
$pageFile = Get-CimInstance Win32_PageFileUsage
$pfTotal = if($pageFile) { ($pageFile | Measure-Object -Property AllocatedBaseSize -Sum).Sum } else { 0 }
$pfUsed = if($pageFile) { ($pageFile | Measure-Object -Property CurrentUsage -Sum).Sum } else { 0 }
"  {0,-20}: {1} MB used of {2} MB" -f "Swap file",$pfUsed,$pfTotal
""

# disc info
Write-Host "DISC:" -ForegroundColor Cyan
#$sysDrive = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID
Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
    if ($_.DeviceID -eq $Env:SystemDrive) { $sysDrive = "[SYS]" } else {$sysDrive = "" }
    "  {0,-20}: Size: {1,8:N2} GB   Free space: {2,8:N2} GB ({3} %) {4}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive
}
#"System drive`t`t: {0} Size: {1:N2} GB | Free space: {2:N2} GB ({3} %)" -f (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
#"  {0,-20}: {1} Size: {2:N2} GB | Free space: {3:N2} GB ({4} %)" -f "System drive",(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
""

# ip info
Write-Host "IP ADDRESS:" -ForegroundColor Cyan
$ip_address=(Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
foreach ($ip in $ip_address) {
    "  {0,-20}: {1}" -f "IPv4",$ip
}

#"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
#"  {0,-20}: {1}" -f "IPV4",$ip_address
""