BeforeAll {
    $script:dscModuleName = 'PSPrintful'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Get-StoreProduct {
    BeforeAll {
        Mock -CommandName Get-StoreProduct -MockWith {
            # This return the value passed to the Get-PrivateFunction parameter $PrivateData.
            $PrivateData
        } -ModuleName $dscModuleName
    }

    Context 'When passing values using named parameters' {
        It 'Should return a single object' {
            $return = Get-StoreProduct -storeId '12935572'

                ($return | Measure-Object).Count | Should -BeGreaterOrEqual 1
        }
        It 'Should return all products with a specific status' {
            $status = (
                'all',
                'synced',
                'unsynced',
                'ignored',
                'imported',
                'discontinued',
                'out_of_stock'
            )
            $return = Get-StoreProduct -storeId '12935572' -status $status[0]

            $return.status | Should -BeIn $status
        }
        It 'Should return products in a category' {
            $return = Get-StoreProduct -categoryId '24'

                ($return | Measure-Object).Count | Should -BeGreaterOrEqual 1
        }
    }
}