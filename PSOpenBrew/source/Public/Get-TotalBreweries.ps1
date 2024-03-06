
function Get-TotalBreweries {
    [CmdletBinding()]
    param (
        
    )
    try {
        $response = Invoke-RestMethod -Uri "https://api.openbrewerydb.org/v1/breweries/meta" -Method Get
        $result = $response.total
    }
    catch {
        Write-Error $_
    }
    return $result
}

