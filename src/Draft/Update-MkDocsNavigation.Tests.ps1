BeforeAll {
    $ScriptPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', '..', '..', 'Scripts', 'Update-MkDocsNavigation.ps1'))
    $ManifestPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', '..', 'PSPreworkout', 'PSPreworkout.psd1'))
    $MkDocsPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', '..', '..', 'mkdocs.yml'))

    # Source the script to get access to its functions
    . $ScriptPath
}

Describe 'Update-MkDocsNavigation Script Tests' -Tag Unit {
    Context 'Script File Tests' {
        It 'Update-MkDocsNavigation.ps1 should exist' {
            $ScriptPath | Should -Exist
        }

        It 'should have valid PowerShell syntax' {
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Path $ScriptPath -Raw), [ref]$errors)
            $errors.Count | Should -Be 0
        }

        It 'should have comment-based help' {
            $ScriptPath | Should -FileContentMatch '\.SYNOPSIS'
            $ScriptPath | Should -FileContentMatch '\.DESCRIPTION'
            $ScriptPath | Should -FileContentMatch '\.EXAMPLE'
        }
    }

    Context 'Get-FunctionCategory Tests' {
        It 'should categorize Initialize-PSEnvironmentConfiguration as Customize' {
            Get-FunctionCategory -FunctionName 'Initialize-PSEnvironmentConfiguration' | Should -Be 'Customize'
        }

        It 'should categorize Install-CommandNotFoundUtility as Customize' {
            Get-FunctionCategory -FunctionName 'Install-CommandNotFoundUtility' | Should -Be 'Customize'
        }

        It 'should categorize Set-ConsoleFont as Customize' {
            Get-FunctionCategory -FunctionName 'Set-ConsoleFont' | Should -Be 'Customize'
        }

        It 'should categorize Edit-PSReadLineHistoryFile as Customize' {
            Get-FunctionCategory -FunctionName 'Edit-PSReadLineHistoryFile' | Should -Be 'Customize'
        }

        It 'should categorize New-ScriptFromTemplate as Develop' {
            Get-FunctionCategory -FunctionName 'New-ScriptFromTemplate' | Should -Be 'Develop'
        }

        It 'should categorize Get-TypeAccelerator as Develop' {
            Get-FunctionCategory -FunctionName 'Get-TypeAccelerator' | Should -Be 'Develop'
        }

        It 'should categorize Get-LoadedAssembly as Develop' {
            Get-FunctionCategory -FunctionName 'Get-LoadedAssembly' | Should -Be 'Develop'
        }

        It 'should categorize Show-LoadedAssembly as Develop' {
            Get-FunctionCategory -FunctionName 'Show-LoadedAssembly' | Should -Be 'Develop'
        }

        It 'should categorize Get-CommandHistory as Daily Functions' {
            Get-FunctionCategory -FunctionName 'Get-CommandHistory' | Should -Be 'Daily Functions'
        }

        It 'should categorize Test-IsElevated as Daily Functions' {
            Get-FunctionCategory -FunctionName 'Test-IsElevated' | Should -Be 'Daily Functions'
        }

        It 'should categorize Update-AllTheThings as Daily Functions' {
            Get-FunctionCategory -FunctionName 'Update-AllTheThings' | Should -Be 'Daily Functions'
        }

        It 'should categorize Out-JsonFile as Daily Functions' {
            Get-FunctionCategory -FunctionName 'Out-JsonFile' | Should -Be 'Daily Functions'
        }
    }

    Context 'Get-CategorizedFunctions Tests' {
        BeforeAll {
            if (Test-Path $ManifestPath) {
                $categorized = Get-CategorizedFunctions -ManifestPath $ManifestPath
            } else {
                Write-Warning "Manifest not found at: $ManifestPath"
                $categorized = $null
            }
        }

        It 'should return a hashtable with three categories' {
            if ($null -eq $categorized) {
                Set-ItResult -Skipped -Because "Manifest file not accessible in test environment"
                return
            }
            $categorized | Should -BeOfType [hashtable]
            $categorized.Keys.Count | Should -Be 3
            $categorized.Keys | Should -Contain 'Customize'
            $categorized.Keys | Should -Contain 'Develop'
            $categorized.Keys | Should -Contain 'Daily Functions'
        }

        It 'should have functions in Customize category' {
            if ($null -eq $categorized) {
                Set-ItResult -Skipped -Because "Manifest file not accessible in test environment"
                return
            }
            $categorized['Customize'].Count | Should -BeGreaterThan 0
        }

        It 'should have functions in Develop category' {
            if ($null -eq $categorized) {
                Set-ItResult -Skipped -Because "Manifest file not accessible in test environment"
                return
            }
            $categorized['Develop'].Count | Should -BeGreaterThan 0
        }

        It 'should have functions in Daily Functions category' {
            if ($null -eq $categorized) {
                Set-ItResult -Skipped -Because "Manifest file not accessible in test environment"
                return
            }
            $categorized['Daily Functions'].Count | Should -BeGreaterThan 0
        }

        It 'should exclude known aliases from categorization' {
            if ($null -eq $categorized) {
                Set-ItResult -Skipped -Because "Manifest file not accessible in test environment"
                return
            }
            $allFunctions = $categorized['Customize'] + $categorized['Develop'] + $categorized['Daily Functions']
            $allFunctions | Should -Not -Contain 'Edit-HistoryFile'
            $allFunctions | Should -Not -Contain 'Get-Assembly'
            $allFunctions | Should -Not -Contain 'Get-PSPortable'
            $allFunctions | Should -Not -Contain 'Init-PSEnvConfig'
            $allFunctions | Should -Not -Contain 'New-Script'
            $allFunctions | Should -Not -Contain 'Show-LoadedAssemblies'
        }

        It 'should have sorted function names within each category' {
            if ($null -eq $categorized) {
                Set-ItResult -Skipped -Because "Manifest file not accessible in test environment"
                return
            }
            $customizeSorted = $categorized['Customize'] | Sort-Object
            $categorized['Customize'] | Should -Be $customizeSorted

            $developSorted = $categorized['Develop'] | Sort-Object
            $categorized['Develop'] | Should -Be $developSorted

            $dailySorted = $categorized['Daily Functions'] | Sort-Object
            $categorized['Daily Functions'] | Should -Be $dailySorted
        }
    }

    Context 'New-NavigationYaml Tests' {
        BeforeAll {
            $testCategories = @{
                Customize       = @('Function1', 'Function2')
                Develop         = @('DevFunction1')
                'Daily Functions' = @('DailyFunction1', 'DailyFunction2', 'DailyFunction3')
            }
            $navLines = New-NavigationYaml -CategorizedFunctions $testCategories
        }

        It 'should return an array of strings' {
            $navLines | Should -HaveCount 11
            $navLines | ForEach-Object { $_ | Should -BeOfType [string] }
        }

        It 'should start with nav: line' {
            $navLines[0] | Should -Be 'nav:'
        }

        It 'should include Home entry' {
            $navLines | Should -Contain '  - Home: "index.md"'
        }

        It 'should include Customize category header' {
            $navLines | Should -Contain '  - Customize:'
        }

        It 'should include Develop category header' {
            $navLines | Should -Contain '  - Develop:'
        }

        It 'should include Daily Functions category header' {
            $navLines | Should -Contain '  - Daily Functions:'
        }

        It 'should format function entries correctly' {
            $navLines | Should -Contain '      - Function1: "Function1.md"'
            $navLines | Should -Contain '      - DevFunction1: "DevFunction1.md"'
            $navLines | Should -Contain '      - DailyFunction1: "DailyFunction1.md"'
        }
    }

    Context 'Integration Tests' {
        BeforeAll {
            # Create a temporary test directory
            $testDir = Join-Path $TestDrive 'mkdocs-test'
            New-Item -Path $testDir -ItemType Directory -Force | Out-Null

            # Create a minimal test manifest
            $testManifest = Join-Path $testDir 'test.psd1'
            @'
@{
    FunctionsToExport = @(
        'Edit-PSReadLineHistoryFile',
        'Install-CommandNotFoundUtility',
        'New-ScriptFromTemplate',
        'Get-CommandHistory',
        'Test-IsElevated',
        # Aliases (should be filtered out)
        'Edit-HistoryFile',
        'Get-Assembly',
        'New-Script'
    )
}
'@ | Set-Content -Path $testManifest

            # Create a minimal mkdocs.yml for testing
            $testMkDocs = Join-Path $testDir 'mkdocs.yml'
            $testContent = @'
site_name: "Test Site"
theme:
  name: material

nav:
  - Home: "index.md"
  - Old Category:
      - OldFunction: "OldFunction.md"

markdown_extensions:
  - pymdownx.superfences
'@
            $testContent | Set-Content -Path $testMkDocs
        }

        It 'should successfully update a test mkdocs.yml file' {
            $categorized = Get-CategorizedFunctions -ManifestPath $testManifest
            $navLines = New-NavigationYaml -CategorizedFunctions $categorized
            $result = Update-MkDocsYaml -MkDocsPath $testMkDocs -NewNavLines $navLines

            $result | Should -BeTrue
        }

        It 'should preserve content before nav section' {
            $content = Get-Content -Path $testMkDocs
            $content | Should -Contain 'site_name: "Test Site"'
            $content | Should -Contain 'theme:'
        }

        It 'should preserve content after nav section' {
            $content = Get-Content -Path $testMkDocs
            $content | Should -Contain 'markdown_extensions:'
            $content | Should -Contain '  - pymdownx.superfences'
        }

        It 'should replace old nav content with new content' {
            $content = Get-Content -Path $testMkDocs
            $content | Should -Not -Contain 'Old Category:'
            $content | Should -Not -Contain 'OldFunction:'
        }

        It 'should include new categorized functions' {
            $content = Get-Content -Path $testMkDocs
            $content | Should -Contain '  - Customize:'
            $content | Should -Contain '  - Develop:'
            $content | Should -Contain '  - Daily Functions:'
        }
    }
}
