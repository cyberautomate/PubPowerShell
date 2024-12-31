# Update all of the helpfiles
Update-Help

# Find all the modules that accept updated help
Get-Module -ListAvailable | Where-Object HelpInfoUri

# Save the help files to the local machine
Save-help -Force -DestinationPath 'D:\SaveHelp'

# Use either command below to access helpfiles
Get-Help
Help

# The various flavors of get-help
Get-Help Get-ChildItem -Full
Get-Help Get-ChildItem -Detailed
Get-Help Get-ChildItem -Examples
Get-Help Get-ChildItem -Online

# The text of the Get-Childitem help in a separate window
Get-Help Get-ChildItem -ShowWindow

# This command opens a separate window with a GUI to run the command
Show-Command Get-ChildItem

# Get all the commands beginning with get- 
Get-help get-

# Get all the commands beginning with stop
Get-help stop*

# Get Help for a specific parameter of a cmdlet
Get-help Get-ChildItem -Parameter Filter

# Search for all about_ Helpfiles
Get-Help about_*

# Get the contents of the about_workflow helpfile
get-help about_workflows

# Create a text file containing the about_workflows
get-help about_workflows | Out-File workflows.txt
notepad workflows.txt