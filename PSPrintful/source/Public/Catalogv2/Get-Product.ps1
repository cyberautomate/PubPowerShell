<#
    .SYNOPSIS
        Returns information about a single or multiple products

    .DESCRIPTION
        This generic description is more than 40 characters long I think.

    .PARAMETER ID
        Id of the specific product

    .PARAMETER All
        Get a list of all products available.

    .EXAMPLE
        Get-Product

    .NOTES
#>
function Get-Product {
    param (
        [Parameter()]
        [string]$id
    )
    $key = Get-Secret -Name PrintfulAPI -Vault Hall -AsPlainText

    if ($id) {
        $uri = "https://api.printful.com/products/$id"
        try {
            $header = [Ordered] @{
                Authorization = "Bearer " + $key
            }
            $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop
            $result = $response.result.product
        }
        catch {
            Write-Error $_
        }
        return $result
    }
    else {
        $uri = "https://api.printful.com/products/"
        try {
            $header = [Ordered] @{
                Authorization = "Bearer " + $key
            }
            $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop
            $result = $response.result
        }
        catch {
            Write-Error $_
        }
        return $result
    }
}