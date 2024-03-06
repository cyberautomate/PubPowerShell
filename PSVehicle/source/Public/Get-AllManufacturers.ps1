function Get-AllManufacturers {
    <#
      .SYNOPSIS
      Sample Function to return input string.

      .DESCRIPTION
      This function is only a sample Advanced function that returns the Data given via parameter Data.

      .EXAMPLE
      Get-Something -Data 'Get me this text'


      .PARAMETER Data
      The Data parameter is the data that will be returned without transformation.
    #>
    [cmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $Data
    )
    $uri = "https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop
        $result = $response.results
    }
    catch {
        Write-Error $_
    }
    return $result
}
