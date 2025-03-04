<#
BeforeAll {
    # Load the module containing the function to be tested
    Import-Module "$PSScriptRoot\..\..\PSPreworkout\PSPreworkout.psm1"
}
#>

Describe 'Get-LoadedAssembly Tests' -Tag Unit {
    Context 'Function Tests' {
        It 'Function should exist' {
            Get-Command -Name Get-LoadedAssembly | Should -Not -BeNullOrEmpty
        }

        It 'Function should have correct alias' {
            Get-Alias -Name 'Get-Assembly' | Should -Not -BeNullOrEmpty
        }

        It 'Function should have valid HelpUri' {
            (Get-Command -Name Get-LoadedAssembly).HelpUri | Should -BeExactly 'https://day3bits.com/PSPreworkout/Get-LoadedAssembly'
        }

        It 'Function should return non-empty output' {
            $result = Get-LoadedAssembly
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
