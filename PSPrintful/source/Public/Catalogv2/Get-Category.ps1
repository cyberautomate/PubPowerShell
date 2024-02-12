<#
    .SYNOPSIS
        Returns information about a single or multiple categories

    .DESCRIPTION
        This generic description is more than 40 characters long I think.

    .PARAMETER Id
        Id of the specific category

    .EXAMPLE
        Get-Category

    .NOTES
#>
function Get-Category {
    param (
        [Parameter()]
        [string]$id
    )
    $key = Get-Secret -Name PrintfulAPI -Vault Hall -AsPlainText

    if ($id) {
        $uri = "https://api.printful.com/categories/$id"
        try {
            $header = [Ordered] @{
                Authorization = "Bearer " + $key
            }
            $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop
            $result = $response.result.category
        }
        catch {
            Write-Error $_
        }
        return $result
    }
    else {
        $uri = "https://api.printful.com/categories/"
        try {
            $header = [Ordered] @{
                Authorization = "Bearer " + $key
            }
            $response = Invoke-RestMethod -Uri $uri -Headers $header -Method Get -ErrorAction Stop
            $result = $response.result.categories
        }
        catch {
            Write-Error $_
        }
        return $result
    }
}