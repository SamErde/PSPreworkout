function Get-ModulesWithUpdate {
    <#
    .SYNOPSIS
    Get a list of installed PowerShell modules that have updates available in the source repository.

    .DESCRIPTION
    This function retrieves a list of installed PowerShell modules and checks for updates available in the source
    repository (e.g.: PowerShell Gallery or MAR).

    It ignores pre-release versions when checking for updates unless a pre-release version is already installed. If a
    pre-release version is already installed, it checks the repository for a newer pre-release version or an equivalent
    (or higher) stable version.

    .PARAMETER Name
    The module name or list of module names to check for updates. Wildcards and arrays are allowed.
    All modules ('*') are checked by default.

    .EXAMPLE
    Get-ModulesWithUpdate
    This command retrieves all installed PowerShell modules and checks for updates available in the source repository.

    .EXAMPLE
    Get-ModulesWithUpdate -PassThru
    This command checks all installed modules for updates. It displays console output while returning PSModuleInfo objects to the pipeline.

    .EXAMPLE
    Get-ModulesWithUpdate -Name 'Pester', 'PSScriptAnalyzer' -PassThru | Update-PSResource
    This command checks specific modules for updates, displays console output about available updates, and pipes the results to Update-PSResource for installation.

    .NOTES
    This function uses Microsoft.PowerShell.PSResourceGet cmdlets for improved performance and functionality.
    The required module will be automatically installed if not present.

    Scope Priority: The function prioritizes CurrentUser scope modules over AllUsers scope modules to match
    PowerShell's natural import behavior. When a module is installed in both scopes, it checks for updates
    against the CurrentUser version since that's what PowerShell would load by default. Use -Verbose to see
    which version and scope is being used for each module.

    To Do:
    - Batch and "paginate" online checks to speed up. Find-PSResource can return multiple results in one request.
    - Add parameter for specifying specific repositories to check.

    #>
    [CmdletBinding()]
    [OutputType('PSPreworkout.ModuleInfo')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Making it pretty.')]
    param(
        # List of modules to check for updates. This parameter is accepts wildcards and checks all modules by default.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Enter a module name or an array of names. Wildcards are allowed.'
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [System.Collections.Generic.List[string]] $Name = @('*'),

        # Display console output while returning module objects to the pipeline.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        # Check for required module and attempt to install if missing
        $RequiredModule = 'Microsoft.PowerShell.PSResourceGet'
        try {
            $PSResourceModule = Get-Module -Name $RequiredModule -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
            if (-not $PSResourceModule) {
                Write-Information "Required module '$RequiredModule' not found. Attempting to install..." -InformationAction Continue
                try {
                    Install-Module -Name $RequiredModule -Scope CurrentUser -AllowClobber -Force -Verbose:$false
                    Write-Information "Successfully installed '$RequiredModule'." -InformationAction Continue
                    Import-Module -Name $RequiredModule -Force -Verbose:$false
                } catch {
                    throw "Failed to install required module '$RequiredModule'. Please install it manually using: Install-Module -Name $RequiredModule"
                }
            } else {
                # Import the module if it's not already imported
                if (-not (Get-Module -Name $RequiredModule)) {
                    Import-Module -Name $RequiredModule -Force -Verbose:$false
                }
            }
        } catch {
            throw "Error checking for required module '$RequiredModule': $_"
        }

        # Get AllUsers scope paths from machine-level PSModulePath for cross-platform compatibility
        $AllUsersModulePaths = @()
        $MachineModulePath = [System.Environment]::GetEnvironmentVariable('PSModulePath', [System.EnvironmentVariableTarget]::Machine)
        if ($MachineModulePath) {
            $AllUsersModulePaths = $MachineModulePath -split [System.IO.Path]::PathSeparator | Where-Object { $_ }
        }
        Write-Debug "AllUsers module paths: $($AllUsersModulePaths -join '; ')"

        # Initialize a list to hold modules with updates.
        [System.Collections.Generic.List[System.Object]] $ModulesWithUpdates = @()
    } # end begin block

    process {
        # Get installed modules.
        try {
            # Optimize the search: if no wildcards are used, search for each module specifically
            $HasWildcards = $Name | Where-Object { $_ -match '[*?]' }

            if ($HasWildcards) {
                # Use wildcard search for patterns like '*', 'Az.*', etc.
                Write-Host "Searching for installed modules matching patterns: $($Name -join ', ')" -ForegroundColor Cyan
                [System.Collections.Generic.List[System.Object]] $Modules = Get-InstalledPSResource -Name $Name -Verbose:$false |
                    Where-Object Type -EQ 'Module' |
                        Group-Object Name |
                            ForEach-Object {
                                # For each module name, prioritize CurrentUser scope over AllUsers scope
                                # Use machine-level PSModulePath to identify AllUsers installations
                                $AllUsersModules = $_.Group | Where-Object {
                                    $ModuleLocation = $_.InstalledLocation
                                    $AllUsersModulePaths | Where-Object { $ModuleLocation.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) }
                                }

                                # CurrentUser modules are everything that's NOT in AllUsers scope
                                $CurrentUserModules = $_.Group | Where-Object {
                                    $ModuleLocation = $_.InstalledLocation
                                    -not ($AllUsersModulePaths | Where-Object { $ModuleLocation.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) })
                                }

                                if ($CurrentUserModules) {
                                    # If module exists in CurrentUser scope, use the highest version from CurrentUser
                                    $SelectedModule = $CurrentUserModules | Sort-Object Version -Descending | Select-Object -First 1
                                    if ($AllUsersModules) {
                                        $HighestAllUsers = $AllUsersModules | Sort-Object Version -Descending | Select-Object -First 1
                                        Write-Verbose "Module '$($_.Name)': Using CurrentUser version $($SelectedModule.Version) (AllUsers has $($HighestAllUsers.Version))"
                                    } else {
                                        Write-Verbose "Module '$($_.Name)': Using CurrentUser version $($SelectedModule.Version)"
                                    }
                                    $SelectedModule
                                } elseif ($AllUsersModules) {
                                    # If only in AllUsers scope, use the highest version from AllUsers
                                    $SelectedModule = $AllUsersModules | Sort-Object Version -Descending | Select-Object -First 1
                                    Write-Verbose "Module '$($_.Name)': Using AllUsers version $($SelectedModule.Version) (no CurrentUser installation)"
                                    $SelectedModule
                                } else {
                                    # Fallback: if we can't determine scope, just use the highest version
                                    $SelectedModule = $_.Group | Sort-Object Version -Descending | Select-Object -First 1
                                    Write-Verbose "Module '$($_.Name)': Using highest version $($SelectedModule.Version) (scope undetermined)"
                                    $SelectedModule
                                }
                            } | Sort-Object Name
            } else {
                # For specific module names without wildcards, search each individually for better performance
                Write-Host "Searching for specific installed modules: $($Name -join ', ')" -ForegroundColor Cyan
                [System.Collections.Generic.List[System.Object]] $AllModules = @()
                foreach ($ModuleName in $Name) {
                    Write-Verbose "Looking for installed module: $ModuleName"
                    $ModuleResults = Get-InstalledPSResource -Name $ModuleName -ErrorAction SilentlyContinue -Verbose:$false |
                        Where-Object Type -EQ 'Module'
                    if ($ModuleResults) {
                        Write-Verbose "Found $($ModuleResults.Count) installation(s) of module '$ModuleName'"
                        $AllModules.AddRange(@($ModuleResults))
                    } else {
                        Write-Verbose "Module '$ModuleName' not found in installed modules"
                    }
                }

                # Group by module name only and select the best version with scope priority
                [System.Collections.Generic.List[System.Object]] $Modules = $AllModules |
                    Group-Object Name |
                        ForEach-Object {
                            # For each module name, prioritize CurrentUser scope over AllUsers scope
                            # Use machine-level PSModulePath to identify AllUsers installations
                            $AllUsersModules = $_.Group | Where-Object {
                                $ModuleLocation = $_.InstalledLocation
                                $AllUsersModulePaths | Where-Object { $ModuleLocation.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) }
                            }

                            # CurrentUser modules are everything that's NOT in AllUsers scope
                            $CurrentUserModules = $_.Group | Where-Object {
                                $ModuleLocation = $_.InstalledLocation
                                -not ($AllUsersModulePaths | Where-Object { $ModuleLocation.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) })
                            }

                            if ($CurrentUserModules) {
                                # If module exists in CurrentUser scope, use the highest version from CurrentUser
                                $SelectedModule = $CurrentUserModules | Sort-Object Version -Descending | Select-Object -First 1
                                if ($AllUsersModules) {
                                    $HighestAllUsers = $AllUsersModules | Sort-Object Version -Descending | Select-Object -First 1
                                    Write-Verbose "Module '$($_.Name)': Using CurrentUser version $($SelectedModule.Version) (AllUsers has $($HighestAllUsers.Version))"
                                } else {
                                    Write-Verbose "Module '$($_.Name)': Using CurrentUser version $($SelectedModule.Version)"
                                }
                                $SelectedModule
                            } elseif ($AllUsersModules) {
                                # If only in AllUsers scope, use the highest version from AllUsers
                                $SelectedModule = $AllUsersModules | Sort-Object Version -Descending | Select-Object -First 1
                                Write-Verbose "Module '$($_.Name)': Using AllUsers version $($SelectedModule.Version) (no CurrentUser installation)"
                                $SelectedModule
                            } else {
                                # Fallback: if we can't determine scope, just use the highest version
                                $SelectedModule = $_.Group | Sort-Object Version -Descending | Select-Object -First 1
                                Write-Verbose "Module '$($_.Name)': Using highest version $($SelectedModule.Version) (scope undetermined)"
                                $SelectedModule
                            }
                        } | Sort-Object Name
            }
        } catch {
            throw $_
        }

        # End the script if no modules were found.
        if (-not $Modules -or $Modules.Count -eq 0) {
            Write-Warning 'No matching modules were found.'
            return
        } else {
            Write-Host "Found $($Modules.Count) installed modules." -ForegroundColor Cyan
        }

        Write-Host 'Checking the repository for newer versions of the modules...' -ForegroundColor Cyan
        foreach ($Module in $Modules) {

            $InstalledVersion = $Module.Version

            # Check for prerelease using PSResourceGet properties (IsPrerelease boolean and Prerelease string)
            $IsPrerelease = $Module.IsPrerelease -or (-not [string]::IsNullOrWhiteSpace($Module.Prerelease)) -or ( $InstalledVersion -match 'alpha|beta|prerelease|preview|rc' )

            if ($IsPrerelease) {
                # Use the dedicated Prerelease property if available, otherwise extract from version string
                if ($Module.Prerelease) {
                    $Prerelease = '-' + $Module.Prerelease
                } elseif ($InstalledVersion -match '-(.+)$') {
                    $Prerelease = '-' + $matches[1]
                } else {
                    $Prerelease = '~~NA~~'
                }
            } else {
                $Prerelease = '~~NA~~'
            }

            try {
                # Determine which repository to check based on the module's source
                $Repository = $null
                if ($Module.Repository -and $Module.Repository -ne 'Unknown') {
                    $Repository = $Module.Repository
                } else {
                    Write-Verbose "No repository information found for '$($Module.Name)', checking all registered repositories."
                }

                # Get the latest online version from the appropriate repository
                $OnlineModule = $null
                try {
                    if ($Repository) {
                        Write-Verbose "Searching repository '$Repository' for module '$($Module.Name)' with Prerelease:$IsPrerelease"
                        $OnlineModule = Find-PSResource -Name $Module.Name -Repository $Repository -Prerelease:$IsPrerelease
                    } else {
                        Write-Verbose "Searching all repositories for module '$($Module.Name)' with Prerelease:$IsPrerelease"
                        $OnlineModule = Find-PSResource -Name $Module.Name -Prerelease:$IsPrerelease
                    }
                } catch {
                    # If the specific search fails, try without specifying repository for prerelease modules
                    if ($IsPrerelease -and $Repository) {
                        Write-Verbose "Repository-specific search failed for prerelease module '$($Module.Name)', trying all repositories"
                        try {
                            $OnlineModule = Find-PSResource -Name $Module.Name -Prerelease:$IsPrerelease
                        } catch {
                            Write-Verbose "All-repository search also failed for '$($Module.Name)'"
                        }
                    }

                    # If still no result, re-throw the original error to be handled by outer catch
                    if (-not $OnlineModule) {
                        throw
                    }
                }

                if (-not $OnlineModule) {
                    Write-Warning "No online version found for module '$($Module.Name)'."
                    continue
                }

                $OnlineVersion = $OnlineModule.Version

                Write-Verbose "$($Module.Name) $InstalledVersion (Installed)"
                Write-Verbose "$($Module.Name) $OnlineVersion (Online)`n"

                # If a newer version is available, create a custom object with PSPreworkout.ModuleInfo type.
                if (
                    (
                        # Compare the version numbers while ignoring the pre-release suffix.
                        # Treat the installed version as an array in case multiple versions are installed.
                        [version]$OnlineVersion.ToString().Replace($Prerelease, '') -gt @([version]$InstalledVersion.ToString().Replace($Prerelease, ''))[0]
                    ) -or
                    (
                        # Check if the version numbers are equal, but the installed version is a pre-release version and the online version is not.
                        # This allows updates from prerelease to stable versions.
                        ( [version]$OnlineVersion.ToString().Replace($Prerelease, '') -ge @([version]($InstalledVersion).ToString().Replace($Prerelease, ''))[0] ) -and
                        ( $OnlineVersion -notmatch $Prerelease -and $InstalledVersion -match $Prerelease)
                    )
                ) {
                    Write-Verbose "$($Module.Name) $($InstalledVersion) --> $($OnlineVersion) 🆕`n"

                    # Create a custom object with PSPreworkout.ModuleInfo type
                    $ModuleInfo = [PSCustomObject]@{
                        PSTypeName      = 'PSPreworkout.ModuleInfo'
                        Name            = $Module.Name
                        Version         = $InstalledVersion
                        Repository      = $Module.Repository
                        Description     = $Module.Description
                        Author          = $Module.Author
                        CompanyName     = $Module.CompanyName
                        Copyright       = $Module.Copyright
                        PublishedDate   = $Module.PublishedDate
                        InstalledDate   = $Module.InstalledDate
                        UpdateAvailable = $true
                        OnlineVersion   = $OnlineVersion
                        ReleaseNotes    = $OnlineModule.ReleaseNotes
                    }
                    # Add the module to the list of modules with updates.
                    $ModulesWithUpdates.Add($ModuleInfo) | Out-Null

                    # Display module information when PassThru is specified
                    if ($PassThru) {
                        Write-Host "$($Module.Name): $($InstalledVersion) → $($OnlineVersion)" -ForegroundColor Green
                    }
                }
            } catch {
                # Handle different types of errors more specifically
                $ErrorMessage = $_.Exception.Message
                if ($ErrorMessage -match "could not be found") {
                    if ($Repository) {
                        Write-Warning "Module '$($Module.Name)' was not found in repository '$Repository'. It may have been installed manually or from a different source."
                    } else {
                        Write-Warning "Module '$($Module.Name)' was not found in any registered repositories. It may have been installed manually or from an unregistered source."
                    }
                } elseif ($ErrorMessage -match "null-valued expression") {
                    Write-Warning "Module '$($Module.Name)' search returned null results. This may indicate a repository connectivity issue or the module may not be available in online repositories."
                } else {
                    Write-Warning "Error checking for updates to module '$($Module.Name)': $ErrorMessage"
                }
            }
        }

        if (-not $ModulesWithUpdates -or $ModulesWithUpdates.Count -eq 0) {
            Write-Host 'No module updates found in the online repository.'
            return
        } else {
            # Return the list of modules with updates to the host or the pipeline.
            Write-Host "Found $($ModulesWithUpdates.Count) modules with updates available." -ForegroundColor Yellow
            $ModulesWithUpdates
        }
    } # end process block
}
