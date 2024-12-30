# Example No Hash table or Calculated Properties
Get-WmiObject -Class WIN32_volume -ComputerName localhost -Filter 'drivetype = 3' | 
Select-Object -Property PScomputerName, 
DriveLetter, 
Label, 
FreeSpace

# Example using a Hash table
Get-WmiObject -Class WIN32_volume -ComputerName localhost -Filter 'drivetype = 3' | 
Select-Object -Property PScomputerName, 
DriveLetter, 
Label, 
@{
    LABEL      = 'FreeSpace(GB)';
    EXPRESSION = { ($_.freespace / 1GB) }
}
# Better but not exactly what we're looking for.

Get-WmiObject -Class WIN32_volume -ComputerName localhost -Filter 'drivetype = 3' | 
Select-Object -Property PScomputerName, 
DriveLetter, 
Label, 
@{
    LABEL      = 'FreeSpace(GB)';
    EXPRESSION = { '{0:N2}' -f ($_.freespace / 1GB) }
}