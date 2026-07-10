Write-Host "System information" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow
""
"Date`t`t`t: {0}" -f (Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
"Computer name`t`t: {0}" -f (hostname)
#"User name`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
"User name`t`t: {0}" -f (whoami)
#"User name`t`t: " -f (whoami) | Write-Host -ForegroundColor Green -NoNewline;"{0}" -f (whoami) | Write-Host
"Operating System`t: {0} {1} ({2})" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption,(Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture,(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
"Last bootup time`t: {0}{1}, {2:dd} {2:MMMM} {2:yyy} {2:hh}:{2:mm}:{2:ss} ({3}d {4})" -f (Get-CimInstance -ClassName win32_operatingSystem).LastBootUpTime.ToString("dddd").ToUpper()[0],(Get-CimInstance -ClassName win32_operatingSystem).LastBootUpTime.ToString("dddd").Substring(1),(Get-CimInstance -ClassName win32_operatingSystem).LastBootUpTime,((Get-Date)-(Get-CimInstance -ClassName win32_operatingSystem).LastBootUpTime).ToString().Split(".")[0],((Get-Date)-(Get-CimInstance -ClassName win32_operatingSystem).LastBootUpTime).ToString().Split(".")[1]
"Model`t`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).Model
"Processor`t`t: {0} ({1} Cores)" -f ((Get-CimInstance -ClassName Win32_Processor).Name),(Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
#"Graphic card`t`t: {0} | VRAM: {1} GB" -f (Get-CimInstance Win32_VideoController).Name,([Math]::Round((Get-CimInstance Win32_VideoController).AdapterRam / 1GB, 2))
#"Graphic card`t`t: {0}" -f (Get-CimInstance Win32_VideoController).Name
"Memory`t`t`t: {0:N2} GB used of {1:N2} GB" -f ([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)-[Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)),([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2))
"System drive`t`t: {0} Size: {1:N2} GB | Free space: {2:N2} GB ({3} %)" -f (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
""