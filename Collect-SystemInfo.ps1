# Collecting System Information using PowerShell
# Coded by FreeBooter

Clear-Host
Write-Host "System Information:" -ForegroundColor Green
Write-Host ""

# Define a function to get startup programs
function Get-StartupPrograms
{
	$startupPrograms = @()
	
	# Get startup items from the registry
	$registryPaths = @(
		"HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
		"HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
	)
	
	foreach ($path in $registryPaths)
	{
		$items = Get-ItemProperty -Path $path
		foreach ($item in $items.PSObject.Properties)
		{
			if ($item.Name -ne "PSPath" -and $item.Name -ne "PSParentPath" -and $item.Name -ne "PSChildName" -and $item.Name -ne "PSDrive" -and $item.Name -ne "PSProvider")
			{
				$startupPrograms += [PSCustomObject]@{
					Name   = $item.Name
					Value  = $item.Value
					Source = $path
				}
			}
		}
	}
	
	# Get startup items from the startup folder
	$startupFolderPaths = @(
		"$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
		"$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Startup"
	)
	
	foreach ($folderPath in $startupFolderPaths)
	{
		$items = Get-ChildItem -Path $folderPath -Filter *.lnk
		foreach ($item in $items)
		{
			$startupPrograms += [PSCustomObject]@{
				Name   = $item.Name
				Value  = $item.FullName
				Source = $folderPath
			}
		}
	}
	
	return $startupPrograms
}

# Define a function to get GPU information
function Get-GPUInfo
{
	Get-WmiObject -Namespace "root\cimv2" -Class "Win32_VideoController" |
	Select-Object -Property Name, AdapterRAM, DriverVersion, VideoProcessor, Caption
}

# Retrieve the last boot-up time
$osInfo = Get-WmiObject -Class Win32_OperatingSystem
$lastBootUpTime = $osInfo.ConvertToDateTime($osInfo.LastBootUpTime)

# Calculate the uptime
$uptime = New-TimeSpan -Start $lastBootUpTime -End (Get-Date)

# Display the uptime
Write-Output "System Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes, $($uptime.Seconds) seconds"




$UpTime = Get-CimInstance -ClassName win32_operatingsystem | Select-Object LastBootUpTime

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

Write-Host ""
Write-Host "Operating System:" $os.Caption
Write-Host ""
Write-Host "Version:" $os.Version
Write-Host ""
Write-Host "Computer Name:" $computerSystem.Name
Write-Host ""
Write-Host "Manufacturer:" $computerSystem.Manufacturer
Write-Host ""
Write-Host "Model:" $computerSystem.Model
Write-Host ""
Write-Host "PC Serial Number: " $Serial.SerialNumber
Write-Host ""
Write-Host "Processor:" $processor.Name
Write-Host ""
Write-Host "BIOS Version:" $bios.SMBIOSBIOSVersion
Write-Host ""
Write-Host "Total Physical Memory:" ($computerSystem.TotalPhysicalMemory / 1GB).ToString("0.00 GB") 
Write-Host ""
Write-Host "Disk Drives:" -ForegroundColor Green


foreach ($drive in $diskDrives)
{
	
	Write-Host "`tDrive Model:" $drive.Model
	Write-Host "`tSize:" ($drive.Size / 1GB).ToString("0.00 GB")
}
Write-Host ""
Write-Host "GPU information:" -ForegroundColor Green

# Call the function and output the information
Get-GPUInfo | Format-Table -AutoSize


Write-Host "Network Adapters:" -ForegroundColor Green
foreach ($adapter in $networkAdapters)
{
	Write-Host "`tAdapter:" $adapter.Description
	Write-Host "`tMAC Address:" $adapter.MACAddress
	Write-Host "`tIP Address:" ($adapter.IPAddress -join ", ")
}
Write-Host ""
Write-Host "Installed Software:" -ForegroundColor Green
foreach ($software in $installedSoftware)
{
	Write-Host ""
	Write-Host "`tName:" $software.DisplayName -ForegroundColor Yellow
    Write-Host "`tVersion:" $software.DisplayVersion
    Write-Host "`tPublisher:" $software.Publisher
    Write-Host "`tInstall Date:" $software.InstallDate
}

Write-Host ""
Write-Host "All the programs that run at startup:" -ForegroundColor Green

# Call the function and output the information
Get-StartupPrograms | Format-Table -AutoSize
