<#
DESCRIPTION
Use WMI to gather hardware and software information remotely from domain clients.
The script pings a list of computernames and runs the inventory on livePCs.txt.
Once all the hardware/software information is collected, all the data is exported
to a CSV file. 
PARAMETER 
ComputerName(s), see the examples below.
EXAMPLE
.\Get-Inventory.ps1 -ComputerName CL1
.\Get-Inventory.ps1 -ComputerName CL1, CL2
.\Get-Inventory.ps1 -ComputerName (Get-Content -Path "C:\computers.txt")
#>

Function Get-Inventory {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string[]]$Computers
    )

    $exportLocation = "$env:HOMEDRIVE\scripts\"

    # Test connection to each computer before getting the inventory info
    foreach ($computer in $Computers) {
        if (Test-Connection -ComputerName $computer -Quiet -count 2) {
            Add-Content -value $computer -path "$exportLocation\livePCs.txt"
        }
        else {
            Add-Content -value $computer -path "$exportLocation\deadPCs.txt"
        }
    }

    # Now that we know which PCs are live on the network
    # proceed with the inventory

    $computers = Get-Content -Path "$exportLocation\livePCs.txt"

    foreach ($computer in $computers) {
        $Bios = Get-WmiObject -Class win32_bios -ComputerName $Computer
        $Hardware = Get-WmiObject -Class Win32_computerSystem -ComputerName $Computer
        $Sysbuild = Get-WmiObject -Class Win32_WmiSetting -ComputerName $Computer
        $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
        $Networks = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $Computer | Where-Object { $_.IPEnabled }
        $driveSpace = Get-WmiObject -Class win32_volume -ComputerName $Computer -Filter 'drivetype = 3' | 
        Select-Object -Property PScomputerName, driveletter, label, @{LABEL = 'GBfreespace'; EXPRESSION = { '{0:N2}' -f ($_.freespace / 1GB) } } |
        Where-Object { $_.driveletter -match 'C:' }
        $cpu = Get-WmiObject -Class Win32_Processor  -ComputerName $computer
        $username = Get-ChildItem "\\$computer\c$\Users" | Sort-Object -Property LastWriteTime -Descending | Select-Object -Property Name, LastWriteTime -First 1
        $totalMemory = [math]::round($Hardware.TotalPhysicalMemory / 1024 / 1024 / 1024, 2)
        $lastBoot = $OS.ConvertToDateTime($OS.LastBootUpTime) 

        $IPAddress = $Networks.IpAddress[0]
        $MACAddress = $Networks.MACAddress
        $systemBios = $Bios.serialnumber

        $OutputObj = New-Object -TypeName PSObject
        $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
        $OutputObj | Add-Member -MemberType NoteProperty -Name Manufacturer -Value $Hardware.Manufacturer
        $OutputObj | Add-Member -MemberType NoteProperty -Name Model -Value $Hardware.Model
        $OutputObj | Add-Member -MemberType NoteProperty -Name Processor_Type -Value $cpu.Name
        $OutputObj | Add-Member -MemberType NoteProperty -Name System_Type -Value $Hardware.SystemType
        $OutputObj | Add-Member -MemberType NoteProperty -Name Operating_System -Value $OS.Caption
        $OutputObj | Add-Member -MemberType NoteProperty -Name Operating_System_Version -Value $OS.version
        $OutputObj | Add-Member -MemberType NoteProperty -Name Operating_System_BuildVersion -Value $SysBuild.BuildVersion
        $OutputObj | Add-Member -MemberType NoteProperty -Name Serial_Number -Value $systemBios
        $OutputObj | Add-Member -MemberType NoteProperty -Name IP_Address -Value $IPAddress
        $OutputObj | Add-Member -MemberType NoteProperty -Name MAC_Address -Value $MACAddress
        $OutputObj | Add-Member -MemberType NoteProperty -Name Last_User -Value $username.Name
        $OutputObj | Add-Member -MemberType NoteProperty -Name User_Last_Login -Value $username.LastWriteTime
        $OutputObj | Add-Member -MemberType NoteProperty -Name C:_FreeSpace_GB -Value $driveSpace.GBfreespace
        $OutputObj | Add-Member -MemberType NoteProperty -Name Total_Memory_GB -Value $totalMemory
        $OutputObj | Add-Member -MemberType NoteProperty -Name Last_ReBoot -Value $lastboot
        $OutputObj | Export-Csv -Path "$exportLocation\pcsinventory.csv" -Append -NoTypeInformation
    }
}