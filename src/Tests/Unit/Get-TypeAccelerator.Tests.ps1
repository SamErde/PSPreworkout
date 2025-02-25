<#
BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'PSPreworkout'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', 'Artifacts', "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}
#>

Describe 'Get-TypeAccelerator Tests' -Tag Unit {
    Context 'Function Tests' {
        It 'Function should exist' {
            Get-Command -Name Get-TypeAccelerator | Should -Not -BeNullOrEmpty
        }

        It 'Function should have valid HelpUri' {
            (Get-Command -Name Get-TypeAccelerator).HelpUri | Should -BeExactly 'https://day3bits.com/PSPreworkout/Get-TypeAccelerator'
        }

        It 'Function should return an object' {
            $result = Get-TypeAccelerator
            $result | Should -BeOfType 'Object'
        }

        It 'Function should return non-empty output' {
            $result = Get-TypeAccelerator
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Function should filter by exact name' {
            $result = Get-TypeAccelerator -Name 'ADSI'
            $result.Name | Should -Contain 'ADSI'
        }

        It 'Function should filter by wildcard name' {
            $result = Get-TypeAccelerator -Name 'ps*'
            $result.Name | Should -Match 'ps.*'
        }
    }
}

# Remove-Module $ModuleName -Force
