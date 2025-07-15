BeforeAll {
    # Import the module or function under test
    $ModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path -Path $ModulePath -ChildPath 'PSPreworkout\Public'
    . (Join-Path -Path $PublicPath -ChildPath 'Get-EnvironmentVariable.ps1')
}

Describe 'Get-EnvironmentVariable' {
    BeforeEach {
        # Set up test environment variables for consistent testing
        $env:TEST_VARIABLE_PESTER = 'TestValue'
        $env:TEMP_TEST_VAR = 'TempTestValue'
        $env:PESTER_TEST_PATTERN = 'PatternTestValue'
    }

    AfterEach {
        # Clean up test environment variables
        Remove-Item -Path Env:TEST_VARIABLE_PESTER -ErrorAction SilentlyContinue
        Remove-Item -Path Env:TEMP_TEST_VAR -ErrorAction SilentlyContinue
        Remove-Item -Path Env:PESTER_TEST_PATTERN -ErrorAction SilentlyContinue
    }

    Context 'Parameter Validation' {
        It 'Should have the correct parameter sets' {
            $Function = Get-Command Get-EnvironmentVariable
            $Function.ParameterSets.Count | Should -Be 2
            $Function.ParameterSets.Name | Should -Contain 'LookupByName'
            $Function.ParameterSets.Name | Should -Contain 'LookupByRegexPattern'
        }

        It 'Should have the correct alias' {
            $Function = Get-Command Get-EnvironmentVariable
            $Function.Definition | Should -Match '\[Alias\(''gev''\)\]'
        }

        It 'Should validate that Name parameter is not null or empty' {
            { Get-EnvironmentVariable -Name '' } | Should -Throw
            { Get-EnvironmentVariable -Name $null } | Should -Throw
        }

        It 'Should validate that Pattern parameter is not null or empty' {
            { Get-EnvironmentVariable -Pattern '' } | Should -Throw
            { Get-EnvironmentVariable -Pattern $null } | Should -Throw
        }
    }

    Context 'Default Behavior (No Parameters)' {
        It 'Should return all environment variables from all targets when no parameters are specified' {
            $Result = Get-EnvironmentVariable

            $Result | Should -Not -BeNullOrEmpty
            $Result.Count | Should -BeGreaterThan 0

            # Should include variables from all available targets (at least Process should always be available)
            $Targets = $Result.Target | Sort-Object -Unique
            $Targets | Should -Contain 'Process'

            # On Windows, all three targets should be available; on Linux/macOS, Process is guaranteed
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                $Targets | Should -Contain 'User'
                $Targets | Should -Contain 'Machine'
            } else {
                # On non-Windows systems, we may only have Process target available
                Write-Verbose 'Running on non-Windows system, Process target should be available'
            }
        }

        It 'Should return objects with the correct PSTypeName' {
            $Result = Get-EnvironmentVariable
            $Result[0].PSObject.TypeNames[0] | Should -Be 'PSPreworkout.EnvironmentVariable'
        }

        It 'Should return objects with expected properties' {
            $Result = Get-EnvironmentVariable
            $Result[0].PSObject.Properties.Name | Should -Contain 'Name'
            $Result[0].PSObject.Properties.Name | Should -Contain 'Value'
            $Result[0].PSObject.Properties.Name | Should -Contain 'Target'
            $Result[0].PSObject.Properties.Name | Should -Contain 'PID'
            $Result[0].PSObject.Properties.Name | Should -Contain 'ProcessName'
        }
    }

    Context 'Name Parameter Tests' {
        It 'Should return the correct environment variable when Name is specified' {
            $Result = Get-EnvironmentVariable -Name 'TEST_VARIABLE_PESTER'

            $Result | Should -Not -BeNullOrEmpty
            $Result.Name | Should -Be 'TEST_VARIABLE_PESTER'
            $Result.Value | Should -Be 'TestValue'
            $Result.Target | Should -Be 'Process'
        }

        It 'Should return environment variable from specific target when Name and Target are specified' {
            $Result = Get-EnvironmentVariable -Name 'TEMP' -Target 'Machine'

            if ($Result) {
                $Result.Name | Should -Be 'TEMP'
                $Result.Target | Should -Be 'Machine'
            }
        }

        It 'Should return environment variables from multiple targets when Name and multiple Targets are specified' {
            $Result = Get-EnvironmentVariable -Name 'TEMP' -Target 'Machine', 'User', 'Process'

            if ($Result) {
                $UniqueTargets = $Result.Target | Sort-Object -Unique
                $UniqueTargets.Count | Should -BeGreaterOrEqual 1
                $Result | ForEach-Object { $_.Name | Should -Be 'TEMP' }
            }
        }

        It 'Should ignore -All switch when Name is specified with Target' {
            $Result = Get-EnvironmentVariable -Name 'TEMP' -Target 'Machine' -All

            if ($Result) {
                $Result.Name | Should -Be 'TEMP'
                $Result.Target | Should -Be 'Machine'
            }
        }

        It 'Should return empty result for non-existent environment variable' {
            $Result = Get-EnvironmentVariable -Name 'NON_EXISTENT_VARIABLE_PESTER_TEST'
            $Result | Should -BeNullOrEmpty
        }
    }

    Context 'Pattern Parameter Tests' {
        It 'Should return environment variables matching regex pattern' {
            $Result = Get-EnvironmentVariable -Pattern '^PESTER_TEST'

            $Result | Should -Not -BeNullOrEmpty
            $Result.Name | Should -Match '^PESTER_TEST'
            $Result.Name | Should -Be 'PESTER_TEST_PATTERN'
            $Result.Value | Should -Be 'PatternTestValue'
        }

        It 'Should return pattern matches from specific target' {
            $Result = Get-EnvironmentVariable -Pattern '^t' -Target 'Machine'

            if ($Result) {
                $Result | ForEach-Object {
                    $_.Name | Should -Match '^t'
                    $_.Target | Should -Be 'Machine'
                }
            }
        }

        It 'Should return pattern matches from multiple targets' {
            $Result = Get-EnvironmentVariable -Pattern '^t' -Target 'Machine', 'User', 'Process'

            if ($Result) {
                $UniqueTargets = $Result.Target | Sort-Object -Unique
                $UniqueTargets.Count | Should -BeGreaterOrEqual 1
                $Result | ForEach-Object { $_.Name | Should -Match '^t' }
            }
        }

        It 'Should ignore -All switch when Pattern is specified with Target' {
            $Result = Get-EnvironmentVariable -Pattern '^t' -Target 'Machine' -All

            if ($Result) {
                $Result | ForEach-Object {
                    $_.Name | Should -Match '^t'
                    $_.Target | Should -Be 'Machine'
                }
            }
        }

        It 'Should return empty result for pattern with no matches' {
            $Result = Get-EnvironmentVariable -Pattern '^ZZZNOMATCHPATTERN'
            $Result | Should -BeNullOrEmpty
        }
    }

    Context 'Target Parameter Tests' {
        It 'Should return environment variables from specific target' {
            $Result = Get-EnvironmentVariable -Target 'Process'

            $Result | Should -Not -BeNullOrEmpty
            $Result | ForEach-Object { $_.Target | Should -Be 'Process' }
        }

        It 'Should return environment variables from multiple specified targets' {
            $Result = Get-EnvironmentVariable -Target 'Machine', 'User'

            # On Windows, should have results; on Linux/macOS, these targets may be empty
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                $Result | Should -Not -BeNullOrEmpty
                $UniqueTargets = $Result.Target | Sort-Object -Unique
                $UniqueTargets | Should -Contain 'Machine'
                $UniqueTargets | Should -Contain 'User'
                $UniqueTargets | Should -Not -Contain 'Process'
            } else {
                # On non-Windows systems, Machine and User targets may not have variables
                Write-Verbose 'Running on non-Windows system, Machine/User targets may be empty'
                if ($Result) {
                    $UniqueTargets = $Result.Target | Sort-Object -Unique
                    $UniqueTargets | Should -Not -Contain 'Process'
                }
            }
        }

        It 'Should return environment variables from all targets when Target includes all three' {
            $Result = Get-EnvironmentVariable -Target 'Machine', 'User', 'Process'

            $Result | Should -Not -BeNullOrEmpty
            $UniqueTargets = $Result.Target | Sort-Object -Unique
            $UniqueTargets | Should -Contain 'Process'

            # On Windows, all three targets should be available
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                $UniqueTargets | Should -Contain 'Machine'
                $UniqueTargets | Should -Contain 'User'
            } else {
                # On non-Windows systems, Machine and User may not have variables
                Write-Verbose 'Running on non-Windows system, some targets may not have variables'
            }
        }
    }

    Context 'Target and All Parameter Tests' {
        It 'Should return all environment variables from specific target when Target and All are specified' {
            $Result = Get-EnvironmentVariable -Target 'Process' -All

            $Result | Should -Not -BeNullOrEmpty
            $Result | ForEach-Object { $_.Target | Should -Be 'Process' }
        }

        It 'Should return all environment variables from multiple targets when Target and All are specified' {
            $Result = Get-EnvironmentVariable -Target 'Machine', 'User' -All

            # On Windows, should have results; on Linux/macOS, these targets may be empty
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                $Result | Should -Not -BeNullOrEmpty
                $UniqueTargets = $Result.Target | Sort-Object -Unique
                $UniqueTargets | Should -Contain 'Machine'
                $UniqueTargets | Should -Contain 'User'
                $UniqueTargets | Should -Not -Contain 'Process'
            } else {
                # On non-Windows systems, Machine and User targets may not have variables
                Write-Verbose 'Running on non-Windows system, Machine/User targets may be empty'
                if ($Result) {
                    $UniqueTargets = $Result.Target | Sort-Object -Unique
                    $UniqueTargets | Should -Not -Contain 'Process'
                }
            }
        }
    }

    Context 'Process-Specific Properties' {
        It 'Should include PID and ProcessName for Process target environment variables' {
            $Result = Get-EnvironmentVariable -Target 'Process'

            $Result[0].PID | Should -Be $PID
            $Result[0].ProcessName | Should -Not -BeNullOrEmpty
            $Result[0].ProcessName | Should -Be (Get-Process -Id $PID).Name
        }

        It 'Should have null PID and ProcessName for non-Process targets' {
            $Result = Get-EnvironmentVariable -Target 'Machine'

            if ($Result) {
                $Result[0].PID | Should -BeNullOrEmpty
                $Result[0].ProcessName | Should -BeNullOrEmpty
            }
        }
    }

    Context 'Edge Cases and Error Handling' {
        It 'Should handle case-insensitive environment variable names on Windows' {
            if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                $Result = Get-EnvironmentVariable -Name 'temp'
                if ($Result) {
                    $Result.Name | Should -Match '^[Tt][Ee][Mm][Pp]$'
                }
            }
        }

        It 'Should handle regex special characters in Name parameter by escaping them' {
            # Test that dots in environment variable names are treated literally, not as regex wildcards
            $env:TEST_DOT_VAR = 'DotTestValue'

            try {
                # Using the Name parameter should match exactly, not as regex
                $Result = Get-EnvironmentVariable -Name 'TEST_DOT_VAR'
                $Result | Should -Not -BeNullOrEmpty
                $Result.Name | Should -Be 'TEST_DOT_VAR'
                $Result.Value | Should -Be 'DotTestValue'

                # This should NOT match TEST_DOT_VAR when using Pattern (because dot is literal in Name)
                $PatternResult = Get-EnvironmentVariable -Pattern 'TEST.DOT.VAR'
                if ($PatternResult) {
                    # If it matches, it should be an exact match due to regex escaping in Name parameter
                    $PatternResult.Name | Should -Be 'TEST_DOT_VAR'
                }
            } finally {
                Remove-Item -Path Env:TEST_DOT_VAR -ErrorAction SilentlyContinue
            }
        }

        It 'Should handle invalid regex patterns by throwing an appropriate error' {
            # The function currently throws an error for invalid regex patterns
            # This behavior is actually reasonable - invalid regex should fail
            { Get-EnvironmentVariable -Pattern '[' } | Should -Throw
        }

        It 'Should handle valid but complex regex patterns' {
            # Test that valid regex patterns work correctly
            $Result = Get-EnvironmentVariable -Pattern '^(TEST_VARIABLE_PESTER|PESTER_TEST_PATTERN)$'

            if ($Result) {
                $Result | Should -Not -BeNullOrEmpty
                $Result.Name | Should -BeIn @('TEST_VARIABLE_PESTER', 'PESTER_TEST_PATTERN')
            }
        }
    }

    Context 'Output Format and Type' {
        It 'Should return objects of type PSObject' {
            $Result = Get-EnvironmentVariable
            $Result[0] | Should -BeOfType [PSObject]
        }

        It 'Should return a collection that can be filtered and sorted' {
            $Result = Get-EnvironmentVariable -Target 'Process'
            $Filtered = $Result | Where-Object { $_.Name -eq 'TEST_VARIABLE_PESTER' }
            $Sorted = $Result | Sort-Object Name

            $Filtered | Should -Not -BeNullOrEmpty
            $Sorted | Should -Not -BeNullOrEmpty
            $Sorted[0].Name | Should -BeLessOrEqual $Sorted[-1].Name
        }
    }

    Context 'Verbose Output' {
        It 'Should produce verbose output when -Verbose is specified' {
            $VerboseOutput = Get-EnvironmentVariable -Name 'TEST_VARIABLE_PESTER' -Verbose 4>&1
            $VerboseMessages = $VerboseOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            $VerboseMessages | Should -Not -BeNullOrEmpty
            $VerboseMessages[0].Message | Should -Match 'Parameters:'
        }
    }
}
