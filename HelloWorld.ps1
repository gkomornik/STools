Write-Host "Hello World!!"
"Date: {0}" -f (Get-Date)
"Computer name: {0}" -f (hostname)
"User name: {0}" -f (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
