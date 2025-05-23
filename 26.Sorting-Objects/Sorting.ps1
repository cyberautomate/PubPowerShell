# Selecting
#Default
Get-Process

# All Properties
Get-Process | Select-Object -Property * | Out-GridView

# Sorting
# Changes the default sorting order for Get-Process
Get-Process | Sort-Object CPU

# Minimize the data and sort
Get-Process | Select-Object ProcessName, CPU | Sort-Object CPU -Descending

## Caution
# Mission: Get the top 10 processes by CPU usage (which 10 processes have the most CPU usage)
Get-Process |
Select-Object ProcessName, CPU -First 10 |
Sort-Object CPU -Descending

# or

Get-Process |
Sort-Object CPU -Descending |
Select-Object ProcessName, CPU -First 10