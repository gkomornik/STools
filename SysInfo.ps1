########################################################################################################################
#                                                                                                                      #
#        System information summary                                                                                    #
#                                                                                                                      #
#        Copyright © 2026 by Grzegorz Komornik. All Rights Reserved.                                                   #
#                                                                                                                      #
########################################################################################################################
#$Error.Clear()
$t_start = Get-Date

Write-Host "====================================================================================================" -ForegroundColor Yellow
Write-Host "                                     SYSTEM INFORMATION SUMMARY                                     " -ForegroundColor Yellow
Write-Host "====================================================================================================" -ForegroundColor Yellow
#"Date`t`t`t: {0}" -f (Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
#"{0,-9}: {1}" -f "Date",(Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
"  {0,-10}: {1}" -f "Date",(Get-Date -Format 'dddd').ToUpper()[0]+(Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss').Substring(1)
#"  {0,-10}: {1}" -f "Date",(Get-Culture).TextInfo.ToTitleCase((Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss'))
#(Get-Culture).TextInfo.ToTitleCase("tekst")

"  {0,-10}: {1}" -f "Report ID",((New-Guid).Guid.ToUpper())

#"{0,-9}: {1}" -f "Computer",(hostname)
#"  {0,-10}: {1}" -f "User name",(Get-CimInstance -ClassName Win32_ComputerSystem).UserName
Write-Host "----------------------------------------------------------------------------------------------------"
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
#"  {0,-16}: {1} {2} ({3})" -f "Name",$os.Caption,$os.OSArchitecture,$os_version.DisplayVersion

if ($null -ne $os_version.DisplayVersion) {
    "  {0,-16}: {1} {2} ({3})" -f "Name",$os.Caption,$os.OSArchitecture,$os_version.DisplayVersion
} else {
    "  {0,-16}: {1} {2}" -f "Name",$os.Caption,$os.OSArchitecture
}
"  {0,-16}: {1}.{2}" -f "Version",$os_version.CurrentBuildNumber,$os_version.UBR
"  {0,-16}: {1}" -f "ProductId",$os_version.ProductId
"  {0,-16}: {1}" -f "Language",(Get-Culture).TextInfo.ToTitleCase(([System.Globalization.CultureInfo]::InstalledUICulture).DisplayName)

 
$timespan_bootup = (Get-Date)-$os.LastBootUpTime
$timespan_installdate = (Get-Date)-$os.InstallDate
#"Operating System`t: {0} {1} ({2})" -f (Get-CimInstance -ClassName Win32_OperatingSystem).Caption,(Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture,(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
"  {0,-16}: {1}{2}, {3:dd} {3:MMMM} {3:yyy} {3:HH}:{3:mm}:{3:ss} ({4} d {5})" -f "Bootup time",$os.LastBootUpTime.ToString("dddd").ToUpper()[0],$os.LastBootUpTime.ToString("dddd").Substring(1),$os.LastBootUpTime,$timespan_bootup.Days,$timespan_bootup.ToString("hh\:mm\:ss")
"  {0,-16}: {1}{2}, {3:dd} {3:MMMM} {3:yyy} {3:HH}:{3:mm}:{3:ss} ({4} d {5})" -f "InstallDate",$os.InstallDate.ToString("dddd").ToUpper()[0],$os.InstallDate.ToString("dddd").Substring(1),$os.InstallDate,$timespan_installdate.Days,$timespan_installdate.ToString("hh\:mm\:ss")
"  {0,-16}: {1}" -f "TimeZone",(Get-CimInstance -ClassName Win32_TimeZone).Caption
""

# query user sessions
Write-Host "QUERY USER:" -ForegroundColor Cyan
$Sessions = query user 2>&1 | ForEach-Object {
    if ($_ -match '^(?<Active>>)?\s*(?<User>[^\s]+)\s+(?<Session>[^\s]*)\s+(?<ID>\d+)\s+(?<State>[^\s]+)\s+(?<IdleTime>[^\s]+)\s+(?<LogonTime>.+)$') {
        [PSCustomObject]@{
            User       = $Matches.User
            ID         = $Matches.ID
            State      = $Matches.State -replace 'Disc', 'Disconnected'
            Session    = $Matches.Session
            LogonTime  = $Matches.LogonTime.Trim()
        }
    }
}
#$Sessions | Format-Table
$Sessions | ForEach-Object {
    "  {0,-16}: ID: {1,2}  State: {2,-8}  Session: {3,-8}  Time: {4}" -f $_.User,$_.ID,$_.State,$_.Session,$_.LogonTime
}
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
    "  {0,-16}: {1,-23}  Type: {2,-10}  Time: {3}" -f "Name",($_.Domain+"\"+$_.UserName),$_.LogonType,$_.StartTime
    }
""

#Get-CimInstance -ClassName win32_process -Filter "Name like 'explorer.exe'" | % {"User name: {0}:   StartTime: {1}" -f ((Invoke-CimMethod $_ -MethodName GetOwner).Domain+"\"+(Invoke-CimMethod $_ -MethodName GetOwner).User),$_.CreationDate}
$RemotingUsers = Get-CimInstance -ClassName Win32_Process -Filter "Name='wsmprovhost.exe'" -ComputerName $Computer | ForEach-Object {
    $Owner = Invoke-CimMethod -InputObject $_ -MethodName GetOwner
    [PSCustomObject]@{
        User       = $Owner.User
        LogonType  = "PowerShell Remoting (WinRM)"
        StartTime  = $_.CreationDate
    }
}

if ($RemotingUsers) {
    Write-Host "POWERSHELL WinRM:" -ForegroundColor Cyan
    $RemotingUsers | ForEach-Object {
        "  {0,-16}: {1,-15} Time: {2}" -f "Name",$_.User,$_.StartTime
    }
    ""
}

# processor info
Write-Host "PROCESSOR:" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_Processor | ForEach-Object {
    #"  {0,-16}: {1} ({2} Cores)" -f "Model",$_.Name,$_.NumberOfLogicalProcessors
    "  {0,-16}: {1}" -f "Model",$_.Name
    "  {0,-16}  Max Clock Speed     : {1:N2} GHz" -f "",[Math]::Round($_.MaxClockSpeed / 1000, 2)
    "  {0,-16}  Logical Processors  : {1}" -f "",$_.NumberOfLogicalProcessors
    ""
}
#"Processor`t`t: {0} ({1} Cores)" -f ((Get-CimInstance -ClassName Win32_Processor).Name),(Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
#""

# base board info 
Write-Host "BASE BOARD:" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_BaseBoard | ForEach-Object {
    "  {0,-16}: {1}" -f "Model",$_.Product
    "  {0,-16}: {1}" -f "Manufacturer",$_.Manufacturer
    "  {0,-16}: {1}" -f "Version",$_.Version
    ""
}

# bios info 
Write-Host "BIOS:" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_Bios | ForEach-Object {
    "  {0,-16}: {1}" -f "Manufacturer",$_.Manufacturer
    "  {0,-16}: {1}" -f "SMBIOSBIOSVer",$_.SMBIOSBIOSVersion
    "  {0,-16}: {1}" -f "Version",$_.Version
    "  {0,-16}: {1}" -f "SerialNumber",$_.SerialNumber
    ""
}


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

# memory & page file info
Write-Host "MEMORY:" -ForegroundColor Cyan
#$mem = Get-CimInstance Win32_OperatingSystem
$totalRam = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRam = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedRam = $totalRam - $freeRam
#"Memory`t`t`t: {0:N2} GB used of {1:N2} GB" -f ([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2)-[Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)),([Math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB, 2))
"  {0,-16}: {1,5:N2} GB used of {2,5:N2} GB ({3} %)" -f "Ram",$usedRam,$totalRam,[Math]::Round((($usedRam/$totalRam)*100),1)
$pageFile = Get-CimInstance Win32_PageFileUsage
$pfTotal = if($pageFile) { ($pageFile | Measure-Object -Property AllocatedBaseSize -Sum).Sum } else { 0 }
$pfUsed = if($pageFile) { ($pageFile | Measure-Object -Property CurrentUsage -Sum).Sum } else { 0 }
$pfPeak= if($pageFile) { ($pageFile | Measure-Object -Property PeakUsage -Sum).Sum } else { 0 }
"  {0,-16}: {1,5} MB used of {2,5} MB ({3} %) {4,5}: {5} MB" -f "Swap file",$pfUsed,$pfTotal,[Math]::Round(($pfUsed/$pfTotal)*100,1),"Peak",$pfPeak
""

# disk drive
<#
Write-Host "DISK DRIVE:" -ForegroundColor Cyan
#Get-CimInstance -ClassName Win32_DiskDrive | Format-Table @{Label="Disk Drive";Expression={$_.Caption}},@{Label="Size";Expression={$_.Size / 1gb}}
Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
    #"  {0,-16}: {1,-30} Size: {2,7:N2} GB SN: {3}" -f "Name",$_.Caption,($_.Size / 1GB),$_.SerialNumber
    "  {0,-16}: {1,-30} Size: {2,7:N2} GB" -f "Name",$_.Caption,($_.Size / 1GB)
}
""
#>

# physical memory
Write-Host "PHYSICAL MEMORY:" -ForegroundColor Cyan
Get-CimInstance -ClassName Win32_PhysicalMemory | ForEach-Object {
    #"  {0,-16}: PartNumber          : {1}" -f $_.Manufacturer,$_.PartNumber
    "  {0,-16}: {1}" -f "Manufacturer",$_.Manufacturer
    "  {0,-16}  PartNumber          : {1}" -f "",$_.PartNumber
    "  {0,-16}  SerialNumber        : {1}" -f "",$_.SerialNumber
    "  {0,-16}  Capacity            : {1} GB" -f "",($_.Capacity / 1GB)
    "  {0,-16}  DeviceLocator       : {1}" -f "",$_.DeviceLocator
    if (![string]::IsNullOrEmpty($_.Speed)) {
        "  {0,-16}  Speed               : {1} MHz" -f "",$_.Speed
    }
    ""
}
"  {0,-16}: {1} GB" -f "Total size",((get-CimInstance -ClassName win32_physicalmemory | Measure-Object -Property Capacity -Sum).Sum /1gb)
""

#Format-Table @{Label="Disk Drive";Expression={$_.Caption}},@{Label="Size";Expression={$_.Size / 1gb}}

#if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {$isBitLockerCMDSupport=$true} else {$isBitLockerCMDSupport=$false}
if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
    try {
        $isBitLockerCMDSupport=$true
        Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop | Out-Null
    }
    catch {
        <#Do this if a terminating exception happens#>
        $isBitLockerCMDSupport=$false
    }
} else {
    $isBitLockerCMDSupport=$false
}

#Write-Host $isBitLockerCMDSupport -ForegroundColor Green

# logical disc info
Write-Host "LOGICAL DISC:" -ForegroundColor Cyan
#$sysDrive = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID
Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
    if ($_.DeviceID -eq $Env:SystemDrive) { $sysDrive = "[SYSTEM DRIVE]" } else { $sysDrive = "" }

    $avgDiskQueueLength=-1
        # windows version "en-US"
        if (([System.Globalization.CultureInfo]::InstalledUICulture).Name -eq "en-US") {
            #"\PhysicalDisk($((Get-Partition -DriveLetter $_.DeviceID.Substring(0,1)).DiskNumber) $($_.DeviceID))\Avg. Disk Queue Length"
            try {
                $avgDiskQueueLength=(Get-counter -Counter "\PhysicalDisk($((Get-Partition -DriveLetter $_.DeviceID.Substring(0,1)).DiskNumber) $($_.DeviceID))\Avg. Disk Queue Length" -ErrorAction Stop).CounterSamples[0].CookedValue
            }
            catch {
                <#Do this if a terminating exception happens#>
            }
        }
        # windows version "pl-PL"
        if (([System.Globalization.CultureInfo]::InstalledUICulture).Name -eq "pl-PL") {
            try {
                $avgDiskQueueLength=(Get-counter -Counter "\Dysk fizyczny($((Get-Partition -DriveLetter $_.DeviceID.Substring(0,1)).DiskNumber) $($_.DeviceID))\Średnia długość kolejki dysku" -ErrorAction Stop).CounterSamples[0].CookedValue
            }
            catch {
                <#Do this if a terminating exception happens#>
            }
        }

    #Write-Warning (Get-Partition -DriveLetter $_.DeviceID.Substring(0,1)).DiskNumber
    #Write-Warning (Get-PhysicalDisk -DeviceNumber (Get-Partition -DriveLetter $_.DeviceID.Substring(0,1)).DiskNumber)
    #$physicalDisk = Get-PhysicalDisk -DeviceNumber ((Get-Partition -DriveLetter $_.DeviceID.Substring(0,1)).DiskNumber)

    #"  {0,-20}: Size: {1,8:N2} GB   Free space: {2,8:N2} GB ({3} %) {4}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive

    <#
    if ($isAdmin -and $isBitLockerCMDSupport) {
        #"  {0,-16}: Size: {1,7:N2} GB   Free: {2,7:N2} GB ({3} %)  {4,5}  BitLocker: {5}" -f ($_.VolumeName+" ("+$_.DeviceID+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive,((Get-BitLockerVolume -MountPoint $_.DeviceID).protectionStatus)
        #"  {0,-16}: Size: {1,7:N2} GB   Free: {2,7:N2} GB ({3} %)  {4,5}  BitLocker: {5}" -f ($_.DeviceID+" ("+$_.VolumeName+")"),($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive,((Get-BitLockerVolume -MountPoint $_.DeviceID).protectionStatus)
        "  {0,-16}: FileSystem: {1,-6} Size: {2,7:N2} GB   Free: {3,7:N2} GB ({4} %)  {5,5}  BitLocker: {6}" -f ($_.DeviceID+" ("+$_.VolumeName+")"),$_.FileSystem,($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive,((Get-BitLockerVolume -MountPoint $_.DeviceID).protectionStatus)
        #"  {0,-16}  Avg Disk Queue Length:  {1:N2}" -f "",$avgDiskQueueLength

        if (-1 -ne $avgDiskQueueLength) {
            "  {0,-16}  Avg Disk Queue Length:  {1:N2}" -f "",$avgDiskQueueLength
        } 
        #"  {0,-16}  HealthStatus:  {1:N2}" -f "",$physicalDisk.HealthStatus
        #"  {0,-16}  BusType:  {1:N2}" -f "",$physicalDisk.BusType
        #"  {0,-16}  MediaType:  {1:N2}" -f "",$physicalDisk.MediaType
        #"  {0,-16}  FirmwareVersion:  {1:N2}" -f "",$physicalDisk.FirmwareVersion


    } else {
        "  {0,-16}: FileSystem: {1,-6} Size: {2,7:N2} GB   Free: {3,7:N2} GB ({4} %)  {5}" -f ($_.DeviceID+" ("+$_.VolumeName+")"),$_.FileSystem,($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive
        "  {0,-16}  Avg Disk Queue Length:  {1:N2}" -f "",$avgDiskQueueLength
    }
    #>
    #"  {0,-16}: FileSystem: {1,-6} Size: {2,7:N2} GB   Free: {3,7:N2} GB ({4} %)  {5,5}" -f ($_.DeviceID+" ("+$_.VolumeName+")"),$_.FileSystem,($_.Size / 1GB),($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1),$sysDrive

    if (![string]::IsNullOrEmpty($_.VolumeName)) {
        "  {0,-16}: FileSystem             : {1,-6}" -f ($_.DeviceID+" ("+$_.VolumeName+")"),$_.FileSystem
    } else {
        "  {0,-16}: FileSystem             : {1,-6}" -f $_.DeviceID,$_.FileSystem
    }
    #"  {0,-16}  Size                   : {1:N2} GB" -f "",($_.Size / 1GB)
    #if (($_.Size / 1TB) -ge 1) {"  {0,-16}  Size                   : {1:N2} TB" -f "",($_.Size / 1TB)} else {"  {0,-16}  Size                   : {1:N2} GB" -f "",($_.Size / 1GB)}
    #"{0} TB" -f ([Math]::Truncate(((1TB - 1) / 1TB) * 100) / 100)
    #"{0} {1} TB" -f "",([Math]::Truncate( ($_.Size / 1TB) * 100 ) / 100)
    if (($_.Size / 1GB) -ge 1000) {
        "  {0,-16}  Size                   : {1} TB" -f "",([Math]::Truncate( ($_.Size / 1TB) * 100 ) / 100)
    } else {
        "  {0,-16}  Size                   : {1:N2} GB" -f "",($_.Size / 1GB)
    }
    "  {0,-16}  Free                   : {1:N2} GB ({2} %)" -f "",($_.FreeSpace / 1GB),[Math]::Round(  (($_.FreeSpace/$_.Size)*100) , 1)

    if ($sysDrive -eq "[SYSTEM DRIVE]") {
        "  {0,-16}  SystemDrive            : {1}" -f "",$true
    }
    if (-1 -ne $avgDiskQueueLength) {
        "  {0,-16}  Avg Disk Queue Length  : {1:N2}" -f "",$avgDiskQueueLength
    } 
    #Write-Warning $avgDiskQueueLength
    if ($isAdmin -and $isBitLockerCMDSupport) {
        "  {0,-16}  BitLocker information" -f ""
        $bitLockerInfo = Get-BitLockerVolume -MountPoint $_.DeviceID
        #"  {0,-16}  BitLocker ProtectionStatus     : {1}" -f "",$bitLockerInfo.ProtectionStatus
        #"  {0,-16}  BitLocker VolumeStatus         : {1}" -f "",$bitLockerInfo.VolumeStatus
        #"  {0,-16}  BitLocker EncryptionPercentage : {1}" -f "",$bitLockerInfo.EncryptionPercentage
        #"  {0,-16}  BitLocker EncryptionMethod     : {1}" -f "",$bitLockerInfo.EncryptionMethod

        "  {0,-16}    ProtectionStatus     : {1}" -f "",$bitLockerInfo.ProtectionStatus
        "  {0,-16}    VolumeStatus         : {1}" -f "",$bitLockerInfo.VolumeStatus
        "  {0,-16}    EncryptionPercentage : {1}" -f "",$bitLockerInfo.EncryptionPercentage
        "  {0,-16}    EncryptionMethod     : {1}" -f "",$bitLockerInfo.EncryptionMethod
    }
    ""
}
if (!$isAdmin -and $isBitLockerCMDSupport) {Write-Host "  * Run with elevated privileges to see information about Bitlocker" -ForegroundColor DarkYellow}
#"System drive`t`t: {0} Size: {1:N2} GB | Free space: {2:N2} GB ({3} %)" -f (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
#"  {0,-20}: {1} Size: {2:N2} GB | Free space: {3:N2} GB ({4} %)" -f "System drive",(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").DeviceID,((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size / 1GB),((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace / 1GB),[Math]::Round((((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").FreeSpace) / ((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Env:SystemDrive'").Size)) * 100, 1)
#""

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

# physical disk
Write-Host "PHYSICAL DISK:" -ForegroundColor Cyan
Get-PhysicalDisk | ForEach-Object {
    "  {0,-16}: {1}" -f $_.DeviceID,$_.Model
    #"  {0,-16}  Size                : {1:N2} GB" -f "",($_.Size / 1GB)


    #"{0} {1} TB" -f "",([Math]::Truncate( ($_.Size / 1TB) * 100 ) / 100)
    #if (($_.Size / 1TB) -ge 1) {"  {0,-16}  Size                : {1:N2} TB" -f "",($_.Size / 1TB)} else {"  {0,-16}  Size                : {1:N2} GB" -f "",($_.Size / 1GB)}
    if (($_.Size / 1GB) -ge 1000) {
        "  {0,-16}  Size                : {1:N2} TB" -f "",([Math]::Truncate( ($_.Size / 1TB) * 100 ) / 100)
    } else {
        "  {0,-16}  Size                : {1:N2} GB" -f "",($_.Size / 1GB)
    }
    "  {0,-16}  BusType             : {1}" -f "",$_.BusType
    "  {0,-16}  MediaType           : {1}" -f "",$_.MediaType
    "  {0,-16}  FirmwareVersion     : {1}" -f "",$_.FirmwareVersion
    "  {0,-16}  LogicalSectorSize   : {1}" -f "",$_.LogicalSectorSize
    "  {0,-16}  PhysicalSectorSize  : {1}" -f "",$_.PhysicalSectorSize
    "  {0,-16}  HealthStatus        : {1}" -f "",$_.HealthStatus
    "  {0,-16}  SerialNumber        : {1}" -f "",$_.SerialNumber
    "  {0,-16}  AdapterSerialNumber : {1}" -f "",$_.AdapterSerialNumber
    ""
}
#""

# TO-DO: Add mac address - done
# Get-NetAdapter -InterfaceIndex 24 | select Name,MacAddress

# ip info
#!Write-Host "IP ADDRESS:" -ForegroundColor Cyan
<#
$ip_address=(Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
foreach ($ip in $ip_address) {
    "  {0,-16}: {1}" -f "IPv4",$ip
}
#>

(Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4) | ForEach-Object {
    #$_
    #!$netAdapter=Get-NetAdapter -InterfaceIndex $_.InterfaceIndex
    #"  {0,-16}: {1,-18} MAC: {2,-20} LinkSpeed: {3,-20}`n  {4,-16}  ifDesc: {5,-16}" -f "IPv4",$_.IPAddress,$netAdapter.MacAddress,$netAdapter.LinkSpeed," ",$netAdapter.ifDesc #,$netAdapter.DriverDescription
    #!"  {0,-16}: {1,-18} MAC: {2,-20} LinkSpeed: {3,-20}`n  {4,-16}  {5,-16}" -f "IPv4",$_.IPAddress,$netAdapter.MacAddress,$netAdapter.LinkSpeed," ",$netAdapter.ifDesc #,$netAdapter.DriverDescription
}

#"IP Address`t`t: {0}" -f (Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4).IPAddress
#"  {0,-20}: {1}" -f "IPV4",$ip_address
""

function Convert-PrefixToSubnetMask ($prefix) {
    if ($prefix -lt 0 -or $prefix -gt 32) {
        return ""
    }
    if ($prefix -eq 0) { return "0.0.0.0" }
   
    $maskArray = [System.BitConverter]::GetBytes([uint32]([Math]::Pow(2, 32) - 1) -shl (32 - $prefix))
    [Array]::Reverse($maskArray)
    return ([System.Net.IPAddress]$maskArray).IPAddressToString
}

# network
Write-Host "NETWORK:" -ForegroundColor Cyan
(Get-NetIPAddress -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex | Where-Object AddressFamily -eq IPv4) | ForEach-Object {
    #$_
    $netAdapter = Get-NetAdapter -InterfaceIndex $_.InterfaceIndex
    $netIPConfiguration = Get-NetIPConfiguration -InterfaceIndex $_.InterfaceIndex
    $prefixLength = (Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4).PrefixLength

    $ipv6=$null
    try {
        $ipv6 = (Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv6 -ErrorAction Stop).IPAddress
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    #"  {0,-16}: {1,-18} MAC: {2,-20} LinkSpeed: {3,-20}`n  {4,-16}  ifDesc: {5,-16}" -f "IPv4",$_.IPAddress,$netAdapter.MacAddress,$netAdapter.LinkSpeed," ",$netAdapter.ifDesc #,$netAdapter.DriverDescription
    #"  {0,-16}: {1,-18} MAC: {2,-20} LinkSpeed: {3,-20}`n  {4,-16}  {5,-16}" -f "IPv4",$_.IPAddress,$netAdapter.MacAddress,$netAdapter.LinkSpeed," ",$netAdapter.ifDesc #,$netAdapter.DriverDescription
    "  {0,-16}: {1}" -f $_.ifIndex,$netAdapter.ifDesc #,$netAdapter.DriverDescription
    "  {0,-16}  IPv4                : {1}" -f "",$_.IPAddress
    #"  {0,-16}  IPv6                : {1}" -f "",(Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv6).IPAddress
    if ($ipv6) {
        #if ($ipv6.GetType().Fullname -eq [System.Object[]]) {
        if ($ipv6 -is [Array]) {
            $ipv6 | ForEach-Object {
                "  {0,-16}  IPv6                : {1}" -f "",$_
            }
        } else {
            "  {0,-16}  IPv6                : {1}" -f "",$ipv6
        }
    }
    "  {0,-16}  Prefix Length       : {1}" -f "",$prefixLength
    "  {0,-16}  Subnet Mask         : {1}" -f "",(Convert-PrefixToSubnetMask -prefix $prefixLength)
    "  {0,-16}  MAC                 : {1}" -f "",$netAdapter.MacAddress
    "  {0,-16}  LinkSpeed           : {1}" -f "",$netAdapter.LinkSpeed
    "  {0,-16}  Default Gateway     : {1}" -f "",(($netIPConfiguration).IPv4DefaultGateway).NextHop
    ($netIPConfiguration).DNSServer | Where-Object {$_.AddressFamily -eq 2} | ForEach-Object {$_.ServerAddresses | ForEach-Object {"  {0,-16}  DNS Servers         : {1}" -f "",$_  }}
    ""
}

# printer
#Write-Host "PRINTERS:" -ForegroundColor Cyan

#Get-Printer | Format-List @{Label="Name";Expression={$_.Name}},@{Label="DriverName";Expression={$_.DriverName}},@{Label="PortName";Expression={$_.PortName.SubString(0,10)}},@{Label="PrinterHostAddress";Expression={$portName=$_.PortName;(Get-PrinterPort | Where-Object {$_.Name -match $portName} | Select-Object PrinterHostAddress).PrinterHostAddress}}
#Get-Printer | Where-Object DriverName -ne "Remote Desktop Easy Print" | Format-List @{Label="Name";Expression={$_.Name}},@{Label="DriverName";Expression={$_.DriverName}},@{Label="PortName";Expression={$_.PortName.SubString(0,10)}},@{Label="PrinterHostAddress";Expression={$portName=$_.PortName;(Get-PrinterPort | Where-Object {$_.Name -match $portName} | Select-Object PrinterHostAddress).PrinterHostAddress}}
<#
Get-Printer | Where-Object DriverName -ne "Remote Desktop Easy Print" | ForEach-Object {
    $portName=$_.PortName
    $printerHostAddress=(Get-PrinterPort | Where-Object {$_.Name -match $portName} | Select-Object PrinterHostAddress).PrinterHostAddress
    "  {0,-16}: {1}" -f "Name",$_.Name
    "  {0,-16}: DriverName          : {1}" -f "",$_.DriverName
    "  {0,-16}: PortName            : {1}" -f "",$_.PortName.SubString(0,20)
    "  {0,-16}: PrinterHostAddress  : {1}" -f "",$printerHostAddress
    ""
}
#>

Write-Host "----------------------------------------------------------------------------------------------------"
"PSVersion: {0}, PSEdition: {1}, CLR: {2}" -f $PSVersionTable.PSVersion,$PSVersionTable.PSEdition,[System.Environment]::Version.ToString() | Write-Host -ForegroundColor DarkGray
"Execution time: {0}" -f ((Get-Date)-$t_start).ToString() | Write-Host -ForegroundColor DarkGray
""
#"Error : {0}" -f $Error.Count | Write-Host -ForegroundColor DarkGray