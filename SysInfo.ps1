Write-Host "System information"
"Date`t`t`t: {0}" -f (Get-Date)
"Computer name`t`t: {0}" -f (hostname)
"User name`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
"Operating System`t: {0}" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
"Model`t`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).Model
"Procesor`t`t: {0}" -f ((Get-CimInstance -ClassName Win32_Processor).Name)
"Memory`t`t`t: {0} used of {1}" -f ([Math]::Round($mem.TotalVisibleMemorySize / 1MB, 2)-[Math]::Round($mem.FreePhysicalMemory / 1MB, 2)),([Math]::Round($mem.TotalVisibleMemorySize / 1MB, 2))
"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
