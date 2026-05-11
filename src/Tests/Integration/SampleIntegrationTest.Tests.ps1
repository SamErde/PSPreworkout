Describe 'Integration Tests' -Tag Integration {
    BeforeAll {
        Set-Location -Path $PSScriptRoot
        $ModuleName = 'PSPreworkout'
        # $PathToManifest = [System.IO.Path]::Combine('..', '..', 'Artifacts', "$ModuleName.psd1")
        # If the module is already in memory, remove it.
        # Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
        # Import-Module $PathToManifest -Force
    }

    AfterAll {
        Get-Module -Name $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    }

    Context 'First Integration Tests' {
        It 'should pass the first integration test' {
            # test logic
        } #it
    }
}
