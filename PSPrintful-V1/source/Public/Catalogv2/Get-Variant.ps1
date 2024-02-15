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
    [CmdletBinding(DefaultParameterSetName = 'variantId')]
    param (
        [Parameter(ParameterSetName = 'variantId', Mandatory = $true, ValueFromPipeline = $true)]
        [string]$variantId
    )
    $key = Get-Secret -Name PrintfulAPI -Vault Hall -AsPlainText
    if ($variantId -ne $null) {
        $uri = "https://api.printful.com/products/variant/$variantId"
        try {
            $header = [Ordered] @{
                Authorization = "Bearer " + $key
            }
            $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop
            $result = $response.result.variant
        }
        catch {
            Write-Error $_
        }
        return $result
    }
}