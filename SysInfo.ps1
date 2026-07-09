Write-Host "==================" -ForegroundColor Yellow
Write-Host "System information" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow
"Date`t`t`t: {0}" -f (Get-Date)
"Computer name`t`t: {0}" -f (hostname)
"User name`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
"Operating System`t: {0}" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
"Model`t`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).Model
"Processor`t`t: {0}" -f ((Get-CimInstance -ClassName Win32_Processor).Name)
"Memory`t`t`t: {0:N2} GB used of {1:N2} GB" -f ([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)-[Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)),([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2))
"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
