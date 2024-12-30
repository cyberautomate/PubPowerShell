function Get-Helpfiles {
    <#
    .SYNOPSIS
        Gets CMDlet help and exports to a txt file.
    .DESCRIPTION
        Gets the help available for every CMDlet in a module or modules and export the contents to a txt file
        If exporting multiple modules, each module uses the module name for the name of the txt file
    .PARAMETER ModuleNames
        The name of the module or modules, see examples for usage with multiple modules.
    .PARAMETER FolderPath
        The folder path where the txt files will be stored
    .EXAMPLE
        Get-Helpfiles -ModuleNames "Bitlocker" -FilePath "C:\folder"
        Returns a txt file for each of the Bitlocker module.
    .EXAMPLE
        Get-Helpfiles -ModuleNames "Bitlocker", "Storage" -FolderPath "C:\Folder"
        Returns a txt file for each of the referenced modules (Bitlocker and Storage)
    .EXAMPLE
        Get-Helpfiles -ModuleNames "Get-Content -Path c:\Sandbox\Help\modules.txt) -FolderPath "C:\Folder"
        Reads the modules.txt file to get the list of modules and returns a
        txt file for each module (Bitlocker and Storage)
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "ModuleNames use Get-Module -ListAvailable to get the Module names"
        )]
        [string[]] $ModuleNames,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Full path for the export file ex. C:\scripts\"
        )]
        [string] $FolderPath
    )
    
    foreach ($module in $ModuleNames) {
        try {

            # Read the content of the .txt file
            $content = Get-Command -Module $module | Get-Help -Full -ErrorAction Stop
            $content | Out-File -FilePath "$FolderPath\$module.txt"
        }
        catch {
            "Error: $($_Get.Exception.Message)"
        }
    }
}