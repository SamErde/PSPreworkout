BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'PSPreworkout'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    $manifestContent = Test-ModuleManifest -Path $PathToManifest
    $moduleCommands = Get-Command -Module $ModuleName
    $moduleExportedFunctions = $moduleCommands | Where-Object CommandType -EQ 'Function' | Select-Object -ExpandProperty Name
    $manifestExportedFunctions = ($manifestContent.ExportedFunctions).Keys
    $manifestExportedAliases = ($manifestContent.ExportedAliases).Keys
}
BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'PSPreworkout'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    $manifestContent = Test-ModuleManifest -Path $PathToManifest
    $moduleCommands = Get-Command -Module $ModuleName
    $moduleExportedFunctions = $moduleCommands | Where-Object CommandType -EQ 'Function' | Select-Object -ExpandProperty Name
    $manifestExportedFunctions = ($manifestContent.ExportedFunctions).Keys
    $manifestExportedAliases = ($manifestContent.ExportedAliases).Keys
}
Describe $ModuleName {

    Context 'Exported Commands' -Fixture {

        Context 'Number of commands' -Fixture {

            It 'Exports the same number of public functions as what is listed in the Module Manifest' {
                $manifestExportedFunctions.Count | Should -BeExactly $moduleExportedFunctions.Count
            }

        }

        Context 'Explicitly exported commands' {

            It 'Includes <_> in the Module Manifest ExportedFunctions' -ForEach $moduleExportedFunctions {
                $manifestExportedFunctions -contains $_ | Should -BeTrue
            }

            It 'Does not include alias <_> in the Module Manifest ExportedFunctions' -ForEach $manifestExportedAliases {
                $manifestExportedFunctions -contains $_ | Should -BeFalse
            }

            It 'Resolves alias <_> to a module command' -ForEach $manifestExportedAliases {
                $alias = Get-Alias -Name $_ -ErrorAction Stop

                $alias.Source | Should -BeExactly $ModuleName
                $manifestExportedFunctions -contains $alias.ResolvedCommandName | Should -BeTrue
            }

        }
    } #context_ExportedCommands

    Context 'Command Help' -Fixture {
        Context '<_>' -Foreach $moduleCommands.Name {

            BeforeEach {
                $help = Get-Help -Name $_ -Full
            }

            It -Name 'Includes a Synopsis' -Test {
                $help.Synopsis | Should -Not -BeNullOrEmpty
            }

            It -Name 'Includes a Description' -Test {
                $help.description.Text | Should -Not -BeNullOrEmpty
            }

            It -Name 'Includes an Example' -Test {
                $help.examples.example | Should -Not -BeNullOrEmpty
            }
        }
    } #context_CommandHelp
}

