# NoGo
Get-Command -Module xPSDesiredStateConfiguration

# NoGo
xService | Get-Member

# Shows all DSC Resources currently installed in PS ModulePath
# Access PSModulepath 
# cd env:
# dir | Where-Object Name -eq PSModulePath
Get-DscResource 

# Get all the DSC Resources in the xPSDesiredStateConfiguration Module
Get-DscResource -Module xPSDesiredStateConfiguration

# How to view the properties of DSC Resources
Get-DscResource -Name xService | Select-Object -ExpandProperty Properties