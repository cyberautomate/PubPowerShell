<#
    .SYNOPSIS
        Returns information about a specific variant of a product

    .DESCRIPTION
        This generic description is more than 40 characters long I think.

    .PARAMETER variantId
        Id of the specific Variant

    .EXAMPLE
        Get-Variant

    .NOTES
#>
function Get-Variant {
    param (
        [Parameter(Mandatory=$true)]
        [string]$variantId
    )
    $uri = "https://api.printful.com/products/variant/$variantId"
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