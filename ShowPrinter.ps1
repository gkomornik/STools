Write-Host "Show Printer"
"Date`t`t`t: {0}" -f (Get-Date)
Get-Printer | Format-List @{Label="Name";Expression={$_.Name}},@{Label="DriverName";Expression={$_.DriverName}},@{Label="PortName";Expression={$_.PortName.SubString(0,10)}},@{Label="PrinterHostAddress";Expression={$portName=$_.PortName;(Get-PrinterPort | Where-Object {$_.Name -match $portName} | Select-Object PrinterHostAddress).PrinterHostAddress}}
