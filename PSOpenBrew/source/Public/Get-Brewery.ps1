<#
    .SYNOPSIS
        Returns information about a specific brewery

    .DESCRIPTION
        This generic description is more than 40 characters long I think.

    .PARAMETER ID
        Id of the specific brewery

    .EXAMPLE


    .NOTES
#>
function Get-Brewery {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$id
    )
    $uri = "https://api.openbrewerydb.org/v1/breweries/$id"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop
        $response
    }
    catch {
        Write-Error $_
    }
    return $result
}