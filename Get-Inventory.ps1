Function Get-Inventory {
  <#
.SYNOPSIS
Gets a variety of computer information remotely and exports it to 
a CSV file.

.PARAMETER Computers
Specifies the Computer names of devices to query

.INPUTS
System.String Get-Inventory can accept a string value to
determine the Computers parameter.

.EXAMPLE
Query one or more computers via a comma separated list.
Get-Inventory -Computers 'BadPC','DC1','SVR12','SVR16' | 
Export-Csv -Path "$env:HOMEPATH\Desktop\pcsinventory.csv" -NoTypeInformation

.EXAMPLE
Query one or more computers via a .txt file. One computer name per line
in the txt file.
Get-Inventory -Computers (Get-Content -Path $env:HOMEPATH\Desktop\computers.txt) | 
Export-Csv -Path "$env:HOMEPATH\Desktop\pcsinventory.csv" -NoTypeInformation

.EXAMPLE
Query ALL computer objects in Active Directory.
** Be Careful running this in large environments **
Get-Inventory -Computers (Get-ADComputer -Filter * | Select-Object -ExpandProperty Name) | 
Export-Csv -Path "$env:HOMEPATH\Desktop\pcsinventory.csv" -NoTypeInformation

.EXAMPLE
Query all computer objects in a specific OU Active Directory.
Get-Inventory -Computers (Get-ADComputer -Filter * -SearchBase 'OU=Servers,DC=DSC,DC=local' | 
Select-Object -ExpandProperty Name) | 
Export-Csv -Path "$env:HOMEPATH\Desktop\pcsinventory.csv" -NoTypeInformation

.LINK

#>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $True)]
    [string[]]$Computers
  )    

  $Result = [Collections.ArrayList]@() 

  $liveComputers = [Collections.ArrayList]@()
  foreach ($computer in $computers) {
    if (Test-Connection -ComputerName $computer -Quiet -count 1) {
      $null = $liveComputers.Add($computer)
    }
    else {
      Write-Verbose -Message ('{0} is unreachable' -f $computer) -Verbose
    }
  }

  $liveComputers | ForEach-Object {
    $biosProps = 'SerialNumber', 'ReleaseDate', 'SMBIOSBIOSVersion', 'SMBIOSMajorVersion',
    'SMBIOSMinorVersion'
    $bios = Get-CimInstance -Class Win32_Bios -ComputerName $_ -Property $biosProps 
    
    $hardware = Get-CimInstance -Class Win32_ComputerSystem -ComputerName $_  
    $totalMemory = [math]::round($hardware.TotalPhysicalMemory/1GB, 2)
  
    $osProps = 'SerialNumber', 'Caption', 'Version', 'LastBootUpTime', 'InstallDate',
    'OSArchitecture', 'BuildNumber'
    $os = Get-CimInstance -Class Win32_OperatingSystem -ComputerName $_ -Property $osProps 
  
    $adapterProps = 'IPAddress', 'IPSubnet', 'DefaultIPGateway', 'MACAddress', 'DHCPEnabled',
    'DHCPServer', 'DHCPLeaseObtained', 'DHCPLeaseExpires', 'Description'
    $adapter = Get-CimInstance -Class Win32_NetworkAdapterConfiguration -ComputerName $_ | 
    Select-Object -Property $adapterProps |
    Where-Object { $_.IPAddress -ne $null }
  
    $drivespaceProps = 'label', 'freespace', 'driveletter'  
    $driveSpace = Get-CimInstance -Class Win32_Volume -ComputerName $_ -Filter 'drivetype = 3' -Property $drivespaceProps | 
    Select-Object -Property driveletter, label, @{LABEL = 'GBfreespace'
      EXPRESSION                                        = { '{0:N2}' -f ($_.freespace/1GB) } 
    } |
    Where-Object { $_.driveletter -match 'C:' }
    
    $cpuProps = 'Name', 'NumberOfCores', 'NumberOfLogicalProcessors', 'VirtualizationFirmwareEnabled'
    $cpu = Get-CimInstance -Class Win32_Processor -ComputerName $_ -Property $cpuProps 
  
    $hotfixProps = 'HotFixID', 'Description', 'InstalledOn'
    $hotFixes = Get-CimInstance -ClassName Win32_QuickFixEngineering -ComputerName $_ -Property $hotfixProps | 
    Select-Object -Property $hotfixProps | 
    Sort-Object InstalledOn -Descending
   
    # create new custom object to keep adding store information to it
    $Result += New-Object -TypeName PSCustomObject -Property @{
      ComputerName             = $_.ToUpper()
      Manufacturer             = $hardware.Manufacturer
      Model                    = $hardware.Model
      SystemType               = $hardware.SystemType
      ProductName              = $os.Caption
      OSVersion                = $os.version
      BuildNumber              = $os.BuildNumber
      OSArchitecture           = $os.OSArchitecture
      OSSerialNumber           = $os.SerialNumber
      SerialNumber             = $bios.SerialNumber
      BIOSReleaseDate          = $bios.ReleaseDate
      BIOSVersion              = $bios.SMBIOSBIOSVersion
      BIOSMajorVersion         = $bios.SMBIOSMajorVersion
      BIOSMinorVersion         = $bios.SMBIOSMinorVersion
      LastBootTime             = $os.LastBootUpTime
      InstallDate              = $os.InstallDate
      IPAddress                = ($adapter.IPAddress -replace (",", "\n") | Out-String)
      SubnetMask               = ($adapter.IPSubnet -replace (",", "\n") | Out-String)
      DefaultGateway           = ($adapter.DefaultIPGateway -replace (",", "\n") | Out-String)
      MACAddress               = ($adapter.MACAddress -replace (",", "\n") | Out-String)
      DHCPEnabled              = ($adapter.DHCPEnabled -replace (",", "\n") | Out-String)
      DHCPServer               = ($adapter.DHCPServer -replace (",", "\n") | Out-String)
      LeaseObtained            = ($adapter.DHCPLeaseObtained -replace (",", "\n") | Out-String)
      LeaseExpires             = ($adapter.DHCPLeaseExpires -replace (",", "\n") | Out-String)
      AdapterInfo              = ($adapter.Description -replace (",", "\n") | Out-String)
      Domain                   = $hardware.Domain
      TotalMemoryGB            = $totalMemory
      CFreeSpaceGB             = $driveSpace.GBfreespace
      CPU                      = $cpu.Name
      CPUCores                 = $cpu.NumberOfCores
      CPULogicalCores          = $cpu.NumberOfLogicalProcessors
      CPUVirtualizationEnabled = $cpu.VirtualizationFirmwareEnabled
      HotFixID                 = ($hotFixes.HotFixID -replace (",", "\n") | Out-String)
      Description              = ($hotFixes.Description -replace (",", "\n") | Out-String)
      InstalledOn              = ($hotFixes.InstalledOn -replace (",", "\n") | Out-String)
    }
  }

  # Column ordering, re-order if you like 
  $colOrder = 'ComputerName', 'Manufacturer', 'Model', 'SystemType',
  'ProductName', 'OSVersion', 'BuildNumber', 'OSArchitecture', 'OSSerialNumber',
  'SerialNumber', 'BIOSReleaseDate', 'BIOSVersion', 'BIOSMajorVersion',
  'BIOSMinorVersion', 'LastBootTime', 'InstallDate', 'Domain',
  'IPAddress', 'SubnetMask', 'DefaultGateway', 'MACAddress',
  'DHCPEnabled', 'DHCPServer', 'LeaseObtained', 'LeaseExpires',
  'AdapterInfo', 'TotalMemoryGB', 'CFreeSpaceGB', 'CPU', 'CPUCores',
  'CPULogicalCores', 'CPUVirtualizationEnabled', 'HotFixID',
  'Description', 'InstalledOn'

  # Return all your results
  $Result | Select-Object -Property $colOrder
}