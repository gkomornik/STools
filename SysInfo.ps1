Write-Host "System information"
"Date`t`t`t: {0}" -f (Get-Date)
"Computer name`t`t: {0}" -f (hostname)
"User name`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
"Operating System`t: {0}" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
"Model`t`t`t: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).Model
"Procesor't't't: {0}" -f ((Get-CimInstance -ClassName Win32_Processor).Name)
"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
