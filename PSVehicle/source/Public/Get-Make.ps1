function Get-Make {
    <#
        .SYNOPSIS
        Sample Function to return input string.

        .DESCRIPTION
        This function is only a sample Advanced function that returns the Data given via parameter Data.

        .EXAMPLE
        Get-Something -Data 'Get me this text'
    #>
    # Get all Makes
    $uri = "https://vpic.nhtsa.dot.gov/api/vehicles/getallmakes?format=json"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop
        $result = $response.results
    }
    catch {
        Write-Error $_
    }
    return $result
}