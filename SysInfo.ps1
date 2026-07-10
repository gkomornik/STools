Write-Host "System information" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow
""
"Date`t`t`t: {0}" -f (Get-Date)
"Computer name`t`t: {0}" -f (hostname)
"User name`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
"Operating System`t: {0} ({1})" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption,(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
"Model`t`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).Model
"Processor`t`t: {0} ({1} Cores)" -f ((Get-CimInstance -ClassName Win32_Processor).Name),(Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
"Memory`t`t`t: {0:N2} GB used of {1:N2} GB" -f ([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)-[Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)),([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2))
"System drive`t`t: {0} Size {1:N2} GB | Free space {2:N2} GB ({3} %)" -f (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
""