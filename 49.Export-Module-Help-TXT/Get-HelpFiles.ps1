function Get-Helpfiles {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "ModuleName use Get-Module -ListAvailable to get the Module names"
        )]
        [string] $ModuleName,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Full path and filename for the export file ex. C:\scripts\export.txt"
        )]
        [string] $FileName
    )
    
    try {
        $files = Get-Command -Module $ModuleName | Get-Help -Full
        $files | Out-File -FilePath $FileName
    }
    catch {
        "ERROR: $_"
    }
}