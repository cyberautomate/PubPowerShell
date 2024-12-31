# Get all Modules, Functions, Alias' ...etc 
# available on your computer
Get-Command -all

# Search for all cmdlets that contain Service 
# in the noun portion.
Get-command –noun Service

# Search for all cmdlets that contain Stop 
# in the verb portion
Get-Command -Verb Stop

# You can also use the * character as a wildcard
Get-command –noun *azure*

# Search for everything in a module, 
# in this case the Azure Module
Get-Command -Module Azure

# Search the Azure Module for all cmdlets
Get-Command -Module Azure -CommandType Cmdlet

# Search the Azure module for all Alias'
Get-Command -Module Azure -CommandType Alias

# Search the PowerShell core modules for Functions
Get-Command -Module Microsoft.PowerShell* -CommandType Function