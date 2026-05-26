Write-Host "Hello World!!"
"Date: {0}" -f (Get-Date)
"Computer name: {0}" -f (hostname)
"User name: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
"Operating System: {0}" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
"Model: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).Model
"IP Address: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
