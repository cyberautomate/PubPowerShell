Function Export-PShelp {
    <#
    SYNOPSIS
    Exports the -full help for each CMDlet available on your computer.
    DESCRIPTION
    Gets all the Modules available on the computer, loops through those Modules to retrieve each CMDlet name as well as create a folder for each module. Loops through each CMDlet in each module and exports the -full help for each to the $filepath\$modulename
    PARAMETER filePath
    -filePath: The folder that you're exporting all the help files to on your local hard drive.
    EXAMPLE
    Export-PShelp -filePath 'c:\helpfiles'
    #>
    
    Param (
        [Parameter(
            Mandatory = $True, HelpMessage = 'Path where you want the helpfiles to be exported',
            Position = 1
        )][string]$filePath
    )
    
    If (!(Test-Path -Path "$filePath\")) {
        New-Item -Path $Filepath -Name Help -ItemType Directory
    }
    
    # You get some errors if a module has no help so I just 
    # turned error reporting off.    
    $ErrorActionPreference = 'silentlycontinue'
    
    # Get each module name and loop through each to retrieve cmdlet names
    $modules = Get-Module -ListAvailable | 
    Select-Object -ExpandProperty Name
    
    ForEach ($module in $modules) {
        # Creates a folder for each Module
        If (!(Get-Item -Path "$filePath\$($module)")) {
            New-Item -ItemType Directory -Path "$filePath\$($module)"
        }
    
        # Get the CMDLet names for each CMDlet in the Module
        $modulecmdlets = Get-Command -Module $module | 
        Select-Object -ExpandProperty name
    
        ForEach ($modulecmdlet in $modulecmdlets) {
            Get-Help -Name $($modulecmdlet) -Full | 
            Out-File -FilePath "$filePath\$($module)\$($modulecmdlet).txt"
        }  
    }
}