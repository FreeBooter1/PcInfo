# Collecting System Information using PowerShell

# Get operating system information
$os = Get-WmiObject -Class Win32_OperatingSystem

# Get computer system information
$computerSystem = Get-WmiObject -Class Win32_ComputerSystem

# Get processor information
$processor = Get-WmiObject -Class Win32_Processor

# Get memory information
$memory = Get-WmiObject -Class Win32_PhysicalMemory

# Get BIOS information
$bios = Get-WmiObject -Class Win32_BIOS

# Get disk drive information
$diskDrives = Get-WmiObject -Class Win32_DiskDrive

# Get network adapter information
$networkAdapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

# Collect installed software information
$installedSoftware = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

# Display the information
Write-Host "Operating System:" $os.Caption
Write-Host "Version:" $os.Version
Write-Host "Computer Name:" $computerSystem.Name
Write-Host "Manufacturer:" $computerSystem.Manufacturer
Write-Host "Model:" $computerSystem.Model
Write-Host "Processor:" $processor.Name
Write-Host "BIOS Version:" $bios.SMBIOSBIOSVersion
Write-Host "Total Physical Memory:" ($computerSystem.TotalPhysicalMemory / 1GB).ToString("0.00") + " GB"
Write-Host "Disk Drives:"
foreach ($drive in $diskDrives) {
    Write-Host "`tDrive Model:" $drive.Model
    Write-Host "`tSize:" ($drive.Size / 1GB).ToString("0.00") + " GB"
}
Write-Host "Network Adapters:"
foreach ($adapter in $networkAdapters) {
    Write-Host "`tAdapter:" $adapter.Description
    Write-Host "`tMAC Address:" $adapter.MACAddress
    Write-Host "`tIP Address:" ($adapter.IPAddress -join ", ")
}
Write-Host "Installed Software:"
foreach ($software in $installedSoftware) {
    Write-Host "`tName:" $software.DisplayName
    Write-Host "`tVersion:" $software.DisplayVersion
    Write-Host "`tPublisher:" $software.Publisher
    Write-Host "`tInstall Date:" $software.InstallDate
}
