<#
    .SYNOPSIS
        Returns information about all variants of a product

    .DESCRIPTION
        This generic description is more than 40 characters long I think.

    .PARAMETER ID
        Id of the specific product

    .PARAMETER All
        Get a list of all products available.

    .EXAMPLE
        Get-AllVariants -id 1

    .NOTES
#>
$key = Get-Secret -Name makekey -Vault vault -AsPlainText
$teamid = '340621'
$uri = "https://us1.make.com/api/v2/data-stores?teamid=$teamid"

$header = [Ordered] @{
    'Authorization' = 'Token ' + $key
    'Content-Type' = 'application/json'
}
$response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop





















function Get-AllVariants {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$id
    )
    $key = Get-Secret -Name PrintfulAPI -Vault Hall -AsPlainText

    $uri = "https://api.printful.com/products/$id"
    try {
        $header = [Ordered] @{
            Authorization = "Bearer " + $key
        }
        $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop
        $result = $response.result.variants
    }
    catch {
        Write-Error $_
    }
    return $result
}