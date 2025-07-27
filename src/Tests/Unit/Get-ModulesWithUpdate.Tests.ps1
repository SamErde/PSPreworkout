BeforeAll {
    # Import the module under test
    $ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $ModulePath = Join-Path -Path $ModuleRoot -ChildPath 'PSPreworkout'
    Import-Module -Name $ModulePath -Force

    # Mock the required dependencies
    Mock -ModuleName PSPreworkout -CommandName Get-InstalledPSResource {
        # Return test data based on the Name parameter
        $TestModules = @(
            [PSCustomObject]@{
                Name = 'TestModule'
                Version = [version]'1.0.0'
                Type = 'Module'
                Repository = 'PSGallery'
                Description = 'Test module description'
                Author = 'Test Author'
                CompanyName = 'Test Company'
                Copyright = '(c) Test'
                PublishedDate = [datetime]'2024-01-01'
                InstalledDate = [datetime]'2024-01-01'
                InstalledLocation = 'C:\Users\Test\Documents\PowerShell\Modules\TestModule\1.0.0'
                IsPrerelease = $false
                Prerelease = $null
            },
            [PSCustomObject]@{
                Name = 'PreReleaseModule'
                Version = [version]'2.0.0'
                Type = 'Module'
                Repository = 'PSGallery'
                Description = 'Prerelease test module'
                Author = 'Test Author'
                CompanyName = 'Test Company'
                Copyright = '(c) Test'
                PublishedDate = [datetime]'2024-01-01'
                InstalledDate = [datetime]'2024-01-01'
                InstalledLocation = 'C:\Users\Test\Documents\PowerShell\Modules\PreReleaseModule\2.0.0'
                IsPrerelease = $true
                Prerelease = 'beta1'
            },
            [PSCustomObject]@{
                Name = 'ThreePartVersion'
                Version = [version]'1.2.3'
                Type = 'Module'
                Repository = 'PSGallery'
                Description = 'Module with 3-part version'
                Author = 'Test Author'
                CompanyName = 'Test Company'
                Copyright = '(c) Test'
                PublishedDate = [datetime]'2024-01-01'
                InstalledDate = [datetime]'2024-01-01'
                InstalledLocation = 'C:\Users\Test\Documents\PowerShell\Modules\ThreePartVersion\1.2.3'
                IsPrerelease = $false
                Prerelease = $null
            },
            [PSCustomObject]@{
                Name = 'FourPartVersion'
                Version = [version]'1.2.3.4'
                Type = 'Module'
                Repository = 'PSGallery'
                Description = 'Module with 4-part version'
                Author = 'Test Author'
                CompanyName = 'Test Company'
                Copyright = '(c) Test'
                PublishedDate = [datetime]'2024-01-01'
                InstalledDate = [datetime]'2024-01-01'
                InstalledLocation = 'C:\Users\Test\Documents\PowerShell\Modules\FourPartVersion\1.2.3.4'
                IsPrerelease = $false
                Prerelease = $null
            }
        )

        # Handle different Name parameter scenarios
        if ($Name -and $Name -ne '*') {
            # Check if it's a wildcard pattern
            if ($Name -like '*Module') {
                return $TestModules | Where-Object { $_.Name -like $Name }
            } else {
                # Direct name match
                return $TestModules | Where-Object { $_.Name -in $Name }
            }
        }
        return $TestModules
    }

    Mock -ModuleName PSPreworkout -CommandName Find-PSResource {
        # Return online versions based on module name
        switch ($Name) {
            'TestModule' {
                return [PSCustomObject]@{
                    Name = 'TestModule'
                    Version = [version]'1.1.0'
                    Repository = 'PSGallery'
                    Description = 'Test module description'
                    Author = 'Test Author'
                    IsPrerelease = $false
                    Prerelease = $null
                    ReleaseNotes = 'Updated version'
                }
            }
            'PreReleaseModule' {
                return [PSCustomObject]@{
                    Name = 'PreReleaseModule'
                    Version = [version]'2.1.0'
                    Repository = 'PSGallery'
                    Description = 'Prerelease test module'
                    Author = 'Test Author'
                    IsPrerelease = $true
                    Prerelease = 'beta2'
                    ReleaseNotes = 'Updated prerelease'
                }
            }
            'ThreePartVersion' {
                return [PSCustomObject]@{
                    Name = 'ThreePartVersion'
                    Version = [version]'1.2'
                    Repository = 'PSGallery'
                    Description = 'Module with 3-part version'
                    Author = 'Test Author'
                    IsPrerelease = $false
                    Prerelease = $null
                    ReleaseNotes = 'No updates'
                }
            }
            'FourPartVersion' {
                return [PSCustomObject]@{
                    Name = 'FourPartVersion'
                    Version = [version]'1.2.3.4'
                    Repository = 'PSGallery'
                    Description = 'Module with 4-part version'
                    Author = 'Test Author'
                    IsPrerelease = $false
                    Prerelease = $null
                    ReleaseNotes = 'No updates'
                }
            }
            default {
                throw "Module '$Name' was not found"
            }
        }
    }

    Mock -ModuleName PSPreworkout -CommandName Get-Command {
        return [PSCustomObject]@{ Name = 'Get-InstalledPSResource' }
    }

    Mock -ModuleName PSPreworkout -CommandName Get-Module {
        return [PSCustomObject]@{ Name = 'Microsoft.PowerShell.PSResourceGet' }
    }

    # Mock all environment-related calls to avoid permission issues
    # The AllUsers path detection is not critical for basic wildcard testing
}

Describe 'Get-ModulesWithUpdate' {
    Context 'Basic Functionality' {
        It 'Should return modules with updates available' {
            $Result = Get-ModulesWithUpdate -Name 'TestModule'

            $Result | Should -Not -BeNullOrEmpty
            $Result.Name | Should -Be 'TestModule'
            $Result.Version | Should -Be ([version]'1.0.0')
            $Result.OnlineVersion | Should -Be ([version]'1.1.0')
            $Result.UpdateAvailable | Should -Be $true
        }

        It 'Should handle prerelease modules correctly' {
            $Result = Get-ModulesWithUpdate -Name 'PreReleaseModule'

            $Result | Should -Not -BeNullOrEmpty
            $Result.Name | Should -Be 'PreReleaseModule'
            $Result.Version | Should -Be ([version]'2.0.0')
            $Result.OnlineVersion | Should -Be ([version]'2.1.0')
            $Result.UpdateAvailable | Should -Be $true
        }

        It 'Should return custom PSPreworkout.ModuleInfo objects' {
            $Result = Get-ModulesWithUpdate -Name 'TestModule'

            $Result.PSTypeNames[0] | Should -Be 'PSPreworkout.ModuleInfo'
        }

        It 'Should include all required properties' {
            $Result = Get-ModulesWithUpdate -Name 'TestModule'

            $Result.Name | Should -Not -BeNullOrEmpty
            $Result.Version | Should -Not -BeNullOrEmpty
            $Result.OnlineVersion | Should -Not -BeNullOrEmpty
            $Result.UpdateAvailable | Should -Be $true
            $Result.Repository | Should -Not -BeNullOrEmpty
            $Result.Description | Should -Not -BeNullOrEmpty
            $Result.Author | Should -Not -BeNullOrEmpty
            $Result.ReleaseNotes | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Version Normalization' {
        It 'Should normalize 3-part versions correctly' {
            # ThreePartVersion: Installed 1.2.3, Online 1.2 -> should normalize to 1.2.3.0 and 1.2.0.0
            $Result = Get-ModulesWithUpdate -Name 'ThreePartVersion'

            # Since 1.2.3.0 > 1.2.0.0, no update should be found
            $Result | Should -BeNullOrEmpty
        }

        It 'Should normalize 4-part versions correctly' {
            # FourPartVersion: Both 1.2.3.4, should be equal after normalization
            $Result = Get-ModulesWithUpdate -Name 'FourPartVersion'

            # Since versions are equal, no update should be found
            $Result | Should -BeNullOrEmpty
        }

        It 'Should handle versions with Build/Revision of -1' {
            # This tests the core issue we fixed with .NET Version normalization
            Mock -ModuleName PSPreworkout -CommandName Get-InstalledPSResource {
                return [PSCustomObject]@{
                    Name = 'BuildRevisionTest'
                    Version = [version]'1.0'  # This creates Build=-1, Revision=-1
                    Type = 'Module'
                    Repository = 'PSGallery'
                    Description = 'Test module'
                    Author = 'Test'
                    CompanyName = 'Test'
                    Copyright = '(c) Test'
                    PublishedDate = [datetime]'2024-01-01'
                    InstalledDate = [datetime]'2024-01-01'
                    InstalledLocation = 'C:\Test'
                    IsPrerelease = $false
                    Prerelease = $null
                }
            } -ParameterFilter { $Name -eq 'BuildRevisionTest' }

            Mock -ModuleName PSPreworkout -CommandName Find-PSResource {
                return [PSCustomObject]@{
                    Name = 'BuildRevisionTest'
                    Version = [version]'1.0.0'  # This creates Build=0, Revision=-1
                    Repository = 'PSGallery'
                    Description = 'Test module'
                    Author = 'Test'
                    IsPrerelease = $false
                    Prerelease = $null
                    ReleaseNotes = 'Test'
                }
            } -ParameterFilter { $Name -eq 'BuildRevisionTest' }

            # This should not throw an error about Build/Revision being -1
            { Get-ModulesWithUpdate -Name 'BuildRevisionTest' } | Should -Not -Throw
        }
    }

    Context 'Prerelease Detection' {
        It 'Should detect prerelease from IsPrerelease property' {
            # This is tested implicitly in the PreReleaseModule test above
            $Result = Get-ModulesWithUpdate -Name 'PreReleaseModule'
            $Result | Should -Not -BeNullOrEmpty
        }

        It 'Should handle modules with unreliable IsPrerelease property' {
            Mock -ModuleName PSPreworkout -CommandName Get-InstalledPSResource {
                return [PSCustomObject]@{
                    Name = 'UnreliablePrerelease'
                    Version = [version]'1.0.0'
                    Type = 'Module'
                    Repository = 'PSGallery'
                    Description = 'Test module'
                    Author = 'Test'
                    CompanyName = 'Test'
                    Copyright = '(c) Test'
                    PublishedDate = [datetime]'2024-01-01'
                    InstalledDate = [datetime]'2024-01-01'
                    InstalledLocation = 'C:\Test'
                    IsPrerelease = $false  # This is unreliable
                    Prerelease = 'beta1'   # But this indicates it's prerelease
                }
            } -ParameterFilter { $Name -eq 'UnreliablePrerelease' }

            Mock -ModuleName PSPreworkout -CommandName Find-PSResource {
                return [PSCustomObject]@{
                    Name = 'UnreliablePrerelease'
                    Version = [version]'1.1.0'
                    Repository = 'PSGallery'
                    Description = 'Test module'
                    Author = 'Test'
                    IsPrerelease = $true
                    Prerelease = 'beta2'
                    ReleaseNotes = 'Test'
                }
            } -ParameterFilter { $Name -eq 'UnreliablePrerelease' -and $Prerelease -eq $true }

            $Result = Get-ModulesWithUpdate -Name 'UnreliablePrerelease'
            $Result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error Handling' {
        It 'Should handle modules not found in repository' {
            Mock -ModuleName PSPreworkout -CommandName Find-PSResource {
                throw "Module 'NonExistentModule' could not be found"
            } -ParameterFilter { $Name -eq 'NonExistentModule' }

            Mock -ModuleName PSPreworkout -CommandName Get-InstalledPSResource {
                return [PSCustomObject]@{
                    Name = 'NonExistentModule'
                    Version = [version]'1.0.0'
                    Type = 'Module'
                    Repository = 'PSGallery'
                    Description = 'Test module'
                    Author = 'Test'
                    CompanyName = 'Test'
                    Copyright = '(c) Test'
                    PublishedDate = [datetime]'2024-01-01'
                    InstalledDate = [datetime]'2024-01-01'
                    InstalledLocation = 'C:\Test'
                    IsPrerelease = $false
                    Prerelease = $null
                }
            } -ParameterFilter { $Name -eq 'NonExistentModule' }

            # Should not throw, but should write a warning
            { Get-ModulesWithUpdate -Name 'NonExistentModule' -WarningAction SilentlyContinue } | Should -Not -Throw
        }

        It 'Should handle version parsing errors gracefully' {
            Mock -ModuleName PSPreworkout -CommandName Get-InstalledPSResource {
                return [PSCustomObject]@{
                    Name = 'BadVersionModule'
                    Version = 'invalid-version'  # This will cause parsing issues
                    Type = 'Module'
                    Repository = 'PSGallery'
                    Description = 'Test module'
                    Author = 'Test'
                    CompanyName = 'Test'
                    Copyright = '(c) Test'
                    PublishedDate = [datetime]'2024-01-01'
                    InstalledDate = [datetime]'2024-01-01'
                    InstalledLocation = 'C:\Test'
                    IsPrerelease = $false
                    Prerelease = $null
                }
            } -ParameterFilter { $Name -eq 'BadVersionModule' }

            # Should not throw, but should write a warning and continue
            { Get-ModulesWithUpdate -Name 'BadVersionModule' -WarningAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context 'Parameter Validation' {
        It 'Should accept wildcard patterns' {
            $Result = Get-ModulesWithUpdate -Name '*Module'
            $Result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept multiple module names' {
            $Result = Get-ModulesWithUpdate -Name @('TestModule', 'PreReleaseModule')
            $Result.Count | Should -Be 2
        }

        It 'Should handle empty results gracefully' {
            Mock -ModuleName PSPreworkout -CommandName Get-InstalledPSResource {
                return @()
            }

            $Result = Get-ModulesWithUpdate -Name 'NonExistentModule'
            $Result | Should -BeNullOrEmpty
        }
    }

    Context 'PassThru Parameter' {
        It 'Should return objects when PassThru is specified' {
            $Result = Get-ModulesWithUpdate -Name 'TestModule' -PassThru
            $Result | Should -Not -BeNullOrEmpty
            $Result.PSTypeNames[0] | Should -Be 'PSPreworkout.ModuleInfo'
        }
    }

    Context 'Scope Priority Logic' {
        BeforeEach {
            # Mock environment paths for scope detection
            Mock -ModuleName PSPreworkout -CommandName Get-ChildItem {
                return @('C:\Program Files\PowerShell\Modules')
            } -ParameterFilter { $Path -like '*Machine*' }
        }

        It 'Should prioritize CurrentUser scope over AllUsers scope' {
            Mock -ModuleName PSPreworkout -CommandName Get-InstalledPSResource {
                return @(
                    [PSCustomObject]@{
                        Name = 'DualScopeModule'
                        Version = [version]'1.0.0'
                        Type = 'Module'
                        Repository = 'PSGallery'
                        Description = 'Test module'
                        Author = 'Test'
                        CompanyName = 'Test'
                        Copyright = '(c) Test'
                        PublishedDate = [datetime]'2024-01-01'
                        InstalledDate = [datetime]'2024-01-01'
                        InstalledLocation = 'C:\Program Files\PowerShell\Modules\DualScopeModule\1.0.0'  # AllUsers
                        IsPrerelease = $false
                        Prerelease = $null
                    },
                    [PSCustomObject]@{
                        Name = 'DualScopeModule'
                        Version = [version]'1.1.0'
                        Type = 'Module'
                        Repository = 'PSGallery'
                        Description = 'Test module'
                        Author = 'Test'
                        CompanyName = 'Test'
                        Copyright = '(c) Test'
                        PublishedDate = [datetime]'2024-01-01'
                        InstalledDate = [datetime]'2024-01-01'
                        InstalledLocation = 'C:\Users\Test\Documents\PowerShell\Modules\DualScopeModule\1.1.0'  # CurrentUser
                        IsPrerelease = $false
                        Prerelease = $null
                    }
                )
            } -ParameterFilter { $Name -eq 'DualScopeModule' }

            Mock -ModuleName PSPreworkout -CommandName Find-PSResource {
                return [PSCustomObject]@{
                    Name = 'DualScopeModule'
                    Version = [version]'1.2.0'
                    Repository = 'PSGallery'
                    Description = 'Test module'
                    Author = 'Test'
                    IsPrerelease = $false
                    Prerelease = $null
                    ReleaseNotes = 'Test'
                }
            } -ParameterFilter { $Name -eq 'DualScopeModule' }

            $Result = Get-ModulesWithUpdate -Name 'DualScopeModule'

            # Should use CurrentUser version (1.1.0) not AllUsers version (1.0.0)
            $Result.Version | Should -Be ([version]'1.1.0')
        }
    }
}

Describe 'Get-ModulesWithUpdate Integration Tests' -Tag 'Integration' {
    Context 'Real Module Dependencies' {
        It 'Should work with Microsoft.PowerShell.PSResourceGet module' {
            # Test that the function can actually load and use the real PSResourceGet module
            # This test will be skipped if the module is not available

            try {
                Import-Module -Name 'Microsoft.PowerShell.PSResourceGet' -ErrorAction Stop
                $Available = $true
            } catch {
                $Available = $false
            }

            if (-not $Available) {
                Set-ItResult -Skipped -Because 'Microsoft.PowerShell.PSResourceGet module is not available'
                return
            }

            # Test with a known stable module that's unlikely to change frequently
            { Get-ModulesWithUpdate -Name 'PackageManagement' -ErrorAction Stop } | Should -Not -Throw
        }
    }
}
