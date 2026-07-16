########################################################################################################################
#                                                                                                                      #
#        System information summary                                                                                    #
#                                                                                                                      #
#        Copyright © 2026 by Grzegorz Komornik. All Rights Reserved.                                                   #
#                                                                                                                      #
########################################################################################################################
$Error.Clear()
$t_start = Get-Date

Write-Host "========================================================================================" -ForegroundColor Yellow
Write-Host "                               SYSTEM INFORMATION SUMMARY                               " -ForegroundColor Yellow
Write-Host "========================================================================================" -ForegroundColor Yellow
#"Date`t`t`t: {0}" -f (Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
#"{0,-9}: {1}" -f "Date",(Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
"  {0,-10}: {1}" -f "Date",(Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
#"  {0,-10}: {1}" -f "Date",(Get-Culture).TextInfo.ToTitleCase((Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss'))
#(Get-Culture).TextInfo.ToTitleCase("tekst")

#"{0,-9}: {1}" -f "Computer",(hostname)
"  {0,-10}: {1}" -f "User name",(Get-CimInstance -ClassName Win32_ComputerSystem).UserName
Write-Host "----------------------------------------------------------------------------------------"
""

$isAdmin=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$cs = Get-CimInstance -ClassName Win32_ComputerSystem

# computer info
Write-Host "COMPUTER:" -ForegroundColor Cyan
"  {0,-16}: {1}" -f "Name",(hostname) #([System.Environment]::MachineName)
if ((0 -ne $os.Description.Length)) {
    "  {0,-16}: {1}" -f "Description",$os.Description
}
"  {0,-16}: {1}" -f "Model",$cs.Model
"  {0,-16}: {1}" -f "Manufacturer",$cs.Manufacturer
#"  {0,-16}: {1}" -f "MachineId",(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SQMClient").MachineId.ToString().Replace('{','').Replace('}','')
"  {0,-16}: {1}" -f "MachineId",(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SQMClient").MachineId.ToString().Trim('{','}')
"  {0,-16}: {1}" -f "Domain",$cs.Domain

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
"  {0,-16}: {1}" -f "Chassis type",$chassisType
"  {0,-16}: {1}" -f "Serial Number",(Get-CimInstance -ClassName Win32_SystemEnclosure).SerialNumber
""

# operating system info
Write-Host "OPERATING SYSTEM:" -ForegroundColor Cyan
#"User name`t`t: {0}" -f (whoami)
#"User name`t`t: " -f (whoami) | Write-Host -ForegroundColor Green -NoNewline;"{0}" -f (whoami) | Write-Host
$os_version = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
"  {0,-16}: {1} {2} ({3})" -f "Name",$os.Caption,$os.OSArchitecture,$os_version.DisplayVersion
"  {0,-16}: {1}.{2}" -f "Version",$os_version.CurrentBuildNumber,$os_version.UBR
"  {0,-16}: {1}" -f "ProductId",$os_version.ProductId


$timespan_bootup = (Get-Date)-$os.LastBootUpTime
$timespan_installdate = (Get-Date)-$os.InstallDate
#"Operating System`t: {0} {1} ({2})" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption,(Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture,(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
"  {0,-16}: {1}{2}, {3:dd} {3:MMMM} {3:yyy} {3:HH}:{3:mm}:{3:ss} ({4} d {5})" -f "Bootup time",$os.LastBootUpTime.ToString("dddd").ToUpper()[0],$os.LastBootUpTime.ToString("dddd").Substring(1),$os.LastBootUpTime,$timespan_bootup.Days,$timespan_bootup.ToString("hh\:mm\:ss")
"  {0,-16}: {1}{2}, {3:dd} {3:MMMM} {3:yyy} {3:HH}:{3:mm}:{3:ss} ({4} d {5})" -f "InstallDate",$os.InstallDate.ToString("dddd").ToUpper()[0],$os.InstallDate.ToString("dddd").Substring(1),$os.InstallDate,$timespan_installdate.Days,$timespan_installdate.ToString("hh\:mm\:ss")
"  {0,-16}: {1}" -f "TimeZone",(Get-CimInstance -ClassName Win32_TimeZone).Caption
""

# logged user
Write-Host "LOGGED USER:" -ForegroundColor Cyan
$LoggedOnUser = Get-CimInstance -ClassName Win32_LogonSession | 
    Where-Object { $_.LogonType -in 2, 10 } | 
    ForEach-Object {
        $Session = $_
        
        $UserRelation = Get-CimInstance -ClassName Win32_LoggedOnUser | 
            Where-Object { $_.Dependent.LogonId -eq $Session.LogonId }
        
        if ($UserRelation) {
            $UserName = $UserRelation.Antecedent.Name
            
            [PSCustomObject]@{
                UserName      = $UserName
                Domain        = $UserRelation.Antecedent.Domain
                LogonType     = if ($Session.LogonType -eq 2) { "Interactive" } else { "Remote (RDP)" }
                StartTime     = $Session.StartTime
            }
        }
    } | Where-Object { $_.UserName -ne $null }

$LoggedOnUser | Group-Object UserName, LogonType | ForEach-Object {
    $_.Group | Sort-Object StartTime | Select-Object -First 1
} | Where-Object {!(($_.UserName -like "DWM-*") -or ($_.UserName -like "UMFD-*"))} | ForEach-Object {
    "  {0,-16}: {1}  Type: {2}  Started: {3}" -f "Name",($_.Domain+"\"+$_.UserName),$_.LogonType,$_.StartTime
    }
""

# processor info
Write-Host "PROCESSOR:" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_Processor | ForEach-Object {
    "  {0,-16}: {1} ({2} Cores)" -f "Name",$_.Name,$_.NumberOfLogicalProcessors
}
#"Processor`t`t: {0} ({1} Cores)" -f ((Get-CimInstance -ClassName Win32_Processor).Name),(Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
""

# video card info
# vram not working

<# this working for nvidia
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\000*" -ErrorAction SilentlyContinue | 
ForEach-Object { 
    if ($_.'HardwareInformation.qwMemorySize') {
        [PSCustomObject]@{
            "Karta Graficzna" = $_.DriverDesc
            "VRAM (GB)"       = [math]::round($_.'HardwareInformation.qwMemorySize' / 1GB, 2)
        }
    }
}#>

Write-Host "VIDEO CARD:" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_VideoController | ForEach-Object {
    #"  {0,-20}: {1,-40} VRAM: {2} GB" -f "Model",$_.Name,[Math]::Round( ($_.AdapterRAM / 1GB), 2)
    "  {0,-16}: {1}" -f "Name",$_.Name
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
"  {0,-16}: {1:N2} GB used of {2:N2} GB ({3} %)" -f "Ram",$usedRam,$totalRam,[Math]::Round((($usedRam/$totalRam)*100),1)
$pageFile = Get-CimInstance Win32_PageFileUsage
$pfTotal = if($pageFile) { ($pageFile | Measure-Object -Property AllocatedBaseSize -Sum).Sum } else { 0 }
$pfUsed = if($pageFile) { ($pageFile | Measure-Object -Property CurrentUsage -Sum).Sum } else { 0 }
"  {0,-16}: {1} MB used of {2} MB ({3} %)" -f "Swap file",$pfUsed,$pfTotal,[Math]::Round(($pfUsed/$pfTotal)*100,1)
""

# disk drive
Write-Host "DISK DRIVE:" -ForegroundColor Cyan
#Get-CimInstance -ClassName Win32_DiskDrive | Format-Table @{Label="Disk Drive";Expression={$_.Caption}},@{Label="Size";Expression={$_.Size / 1gb}}
Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
    #"  {0,-16}: {1,-30} Size: {2,7:N2} GB SN: {3}" -f "Name",$_.Caption,($_.Size / 1GB),$_.SerialNumber
    "  {0,-16}: {1,-30} Size: {2,7:N2} GB" -f "Name",$_.Caption,($_.Size / 1GB)
}
""
#Format-Table @{Label="Disk Drive";Expression={$_.Caption}},@{Label="Size";Expression={$_.Size / 1gb}}

if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {$isBitLockerCMDSupport=$true} else {$isBitLockerCMDSupport=$false}
# logical disc info
Write-Host "LOGICAL DISC:" -ForegroundColor Cyan
#$sysDrive = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID
Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
    if ($_.DeviceID -eq $Env:SystemDrive) { $sysDrive = "[SYS]" } else { $sysDrive = "" }
    #"  {0,-20}: Size: {1,8:N2} GB   Free space: {2,8:N2} GB ({3} %) {4}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive
    if ($isAdmin -and $isBitLockerCMDSupport) {
        "  {0,-16}: Size: {1,7:N2} GB  Free: {2,7:N2} GB ({3} %)  {4,5}  BitLocker: {5}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive,((Get-BitLockerVolume -MountPoint $_.DeviceID).protectionStatus)
    } else {
        "  {0,-16}: Size: {1,7:N2} GB   Free: {2,7:N2} GB ({3} %)  {4}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive
    }
}
if (!$isAdmin -and $isBitLockerCMDSupport) {Write-Host "  * Run with elevated privileges to see information about Bitlocker" -ForegroundColor DarkYellow}
#"System drive`t`t: {0} Size: {1:N2} GB | Free space: {2:N2} GB ({3} %)" -f (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
#"  {0,-20}: {1} Size: {2:N2} GB | Free space: {3:N2} GB ({4} %)" -f "System drive",(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
""

<#
# version 2
Write-Host "LOGICAL DISC: V2" -ForegroundColor Cyan
#$sysDrive = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID
"  {0,-17} {1,-13} {2,-22} {3,-14} {4}" -f "Disc     ","Size       ","Free Space          ","System drive","BitLocker"
"  {0,-17} {1,-13} {2,-22} {3,-14} {4}" -f "=========","===========","====================","============","========="
#"  {0,-17} {1,-13} {2,-22} {3,-14} {4}" -f "----","-----------","--------------------","------------","---------"

Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
    if ($_.DeviceID -eq $Env:SystemDrive) { $sysDrive = "SYSTEM   " } else { $sysDrive = "" }
    #"  {0,-20}: Size: {1,8:N2} GB   Free space: {2,8:N2} GB ({3} %) {4}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive
    if ($isAdmin) {
        "  {0,-17} {1,8:N2} GB {2,10:N2} GB ({3} %) {4,14} {5,8}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive,((Get-BitLockerVolume -MountPoint $_.DeviceID).protectionStatus)
    } else {
        "  {0,-17} {1,8:N2} GB {2,10:N2} GB ({3} %) {4,14}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive
    }
}
if (!$isAdmin) {Write-Host "  * Run with elevated privileges to see information about Bitlocker" -ForegroundColor DarkYellow}
#"System drive`t`t: {0} Size: {1:N2} GB | Free space: {2:N2} GB ({3} %)" -f (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
#"  {0,-20}: {1} Size: {2:N2} GB | Free space: {3:N2} GB ({4} %)" -f "System drive",(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
""
#>


# ip info
Write-Host "IP ADDRESS:" -ForegroundColor Cyan
$ip_address=(Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
foreach ($ip in $ip_address) {
    "  {0,-16}: {1}" -f "IPv4",$ip
}

#"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
#"  {0,-20}: {1}" -f "IPV4",$ip_address
""
Write-Host "----------------------------------------------------------------------------------------"
"Execution time: {0}" -f ((Get-Date)-$t_start).ToString() | Write-Host -ForegroundColor DarkGray
""
#"Error : {0}" -f $Error.Count | Write-Host -ForegroundColor DarkGray