<#
DESCRIPTION
Use the win32_LogicalDisk WMI Class to get Local Disk Information for one
or multiple computers. 
Information gathered: 
System Name    DeviceID   Volume Name  Size(GB)   FreeSpace(GB)  % FreeSpace(GB)   Date
Output options include Out-Gridview, a Table, CSV file and an HTML file.
#>

# Change the $exportpath to whatever path you want the html and CSV files in. 
$exportPath = "C:\scripts\drive_info" # I change this to a central fileshare

# Your computers.txt will need to be in this folder.
$computers = Get-Content "C:\scripts\drive_info\computers.txt"

# This is only used for the HTML file output option.
# If you're not using HTML, you can delete this section
# Start HTML Output file style
$style = "<style>"
$style = $style + "Body{background-color:white;font-family:Arial;font-size:10pt;}"
$style = $style + "Table{border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}"
$style = $style + "TH{border-width: 1px; padding: 2px; border-style: solid; border-color: black; background-color: #cccccc;}"
$style = $style + "TD{border-width: 1px; padding: 5px; border-style: solid; border-color: black; background-color: white;}"
$style = $style + "</style>"
# End HTML Output file style

$driveinfo = Get-WMIobject win32_LogicalDisk -ComputerName $computers -filter "DriveType=3" |
Select-Object SystemName, DeviceID, VolumeName,
@{Name = "Size(GB)"; Expression = { "{0:N1}" -f ($_.size / 1gb) } },
@{Name = "FreeSpace(GB)"; Expression = { "{0:N1}" -f ($_.freespace / 1gb) } },
@{Name = "% FreeSpace(GB)"; Expression = { "{0:N2}%" -f (($_.freespace / $_.size) * 100) } },
@{Name = "Date"; Expression = { $(Get-Date -format 'g') } } 

# Various Output Options
$driveinfo | Out-GridView 
$driveinfo | Format-Table -AutoSize
$driveinfo | Export-Csv "$exportPath\Server_Drivespace.csv" -NoTypeInformation -NoClobber -Append
$driveinfo | ConvertTo-HTML -head $style | Out-File $exportPath\Server_Drivespace.htm -NoClobber -Append