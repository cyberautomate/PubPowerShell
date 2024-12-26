function Get-Helpfiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $moduleName,

        [Parameter(Mandatory = $true)]
        [string] $fileName
    )
    
    try {
        $files = Get-Command -Module $moduleName | Get-Help -Full
        $files | Out-File -FilePath "C:\Sandbox\Help\$fileName"
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
}