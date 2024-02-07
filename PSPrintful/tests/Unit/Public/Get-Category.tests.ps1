BeforeAll {
    $script:dscModuleName = 'PSPrintful'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Get-Category {
    BeforeAll {
        Mock -CommandName Get-Category -MockWith {
            # This return the value passed to the Get-PrivateFunction parameter $PrivateData.
            $PrivateData
        } -ModuleName $dscModuleName
    }
    
    Context 'When passing values using named parameters' {
        It 'Should return a single object' {
            $return = Get-Category -Id '6'
    
                ($return | Measure-Object).Count | Should -Be 1
        }
    
        It 'Should return an object' {
            $return = Get-Category -Id '6'
    
            $return.id | Should -Be '6'
        }
    }
}