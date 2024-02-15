<#
    .SYNOPSIS
        TODO Update Help
        Returns a list of scopes associated with the auth token.

    .DESCRIPTION
        Scopes can be applied programattically to stores or the API token

    .PARAMETER storeId
        The store id of the product

    .PARAMETER status
        The status of the product. Options are all, synced, unsynced, ignored, imported, discontinued, out_of_stock

    .PARAMETER categoryId
        The category id of the product

    .NOTES

    .LINK
        Applicable API endpoint https://api.printful.com/store/products/{id}

    .EXAMPLE
        Get-StoreProducts
#>
function Get-StoreProduct {
    param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$storeId = '12935572',

    [Parameter()]
    [ValidateSet ('all', 'synced', 'unsynced', 'ignored', 'imported', 'discontinued', 'out_of_stock')]
    [string]$status,

    [Parameter(ValueFromPipeline=$true)]
    [string]$categoryId
)
    $key = Get-Secret -Name PrintfulAPI -Vault Hall -AsPlainText

    if ($status) {
        $uri = "https://api.printful.com/store/products?status=$status"
        try {
            $header = [Ordered] @{
                Authorization = "Bearer " + $key
                "X-PF-Store-Id" = $storeId
            }
            $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop
            $result = $response.result
        }
        catch {
            Write-Error $_
        }
        return $result
    }
    else {
        $uri = "https://api.printful.com/store/products"
        try {
            $header = [Ordered] @{
                Authorization = "Bearer " + $key
                "X-PF-Store-Id" = $storeId
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