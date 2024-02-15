<#
    .SYNOPSIS
        Returns the size guide for a specific product

    .DESCRIPTION
        This generic description is more than 40 characters long I think.

    .PARAMETER Id
        Id of the specific Product

    .EXAMPLE
        Get-ProductSizeGuide

    .NOTES
#>
function Get-ProductSizeGuide {
    param (
        [Parameter(Mandatory=$true)]
        [string]$id
    )
    $uri = "https://api.printful.com/products/$id/sizes"
    $key = Get-Secret -Name PrintfulAPI -Vault Hall -AsPlainText

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