function Get-ModulesWithUpdate {
    <#
    .SYNOPSIS
    Get a list of installed PowerShell modules that have updates available in their source repository.

    .DESCRIPTION
    This function retrieves a list of installed PowerShell modules and checks for updates available in their source
    repository (e.g.: PowerShell Gallery or MAR).

    If a pre-release version is installed, it checks the repository for a newer pre-release version or an equivalent
    (or higher) stable version. Otherwise, it only checks for stable updates.

    .PARAMETER Name
    The module name or list of module names to check for updates. Wildcards and arrays are allowed.
    All modules ('*') are checked by default.

    .PARAMETER PassThru
    Display console output while returning module objects to the pipeline. When specified, the function
    will show available updates in the console and also return module objects for further processing.

    .EXAMPLE
    Get-ModulesWithUpdate
    This command retrieves all installed PowerShell modules and checks for updates in their source repository.

    .EXAMPLE
    Get-ModulesWithUpdate -PassThru
    This command checks all installed modules for updates. It returns PSModuleInfo objects to the pipeline and displays
    console output about available updates.

    .EXAMPLE
    Get-ModulesWithUpdate -Name 'Pester', 'PSScriptAnalyzer' -PassThru | Update-PSResource
    This command checks specific modules for updates, displays console output about available updates, and pipes the
    results to Update-PSResource.

    .NOTES
    This function uses Microsoft.PowerShell.PSResourceGet cmdlets for improved performance and functionality over the
    PowerShellGet module's cmdlets. The required module will be automatically installed if not present.

    Scope Priority: The function prioritizes CurrentUser scope modules over AllUsers scope modules, which matches
    PowerShell's own behavior for importing or updating modules. When a module is installed in both scopes, it checks
    for updates against the CurrentUser version since that's what PowerShell would load by default. Use -Verbose to see
    which version and scope is being used for each module.

    To Do:
    - Batch and "paginate" online checks to speed up. Find-PSResource can return multiple results in one request.
    - Add parameter for specifying specific repositories to check.

    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject], [PSPreworkout.ModuleUpdateInfo[]], [Microsoft.PowerShell.PSResourceGet.UtilClasses.PSResourceInfo[]])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Making it pretty.')]
    param(
        # List of modules to check for updates. This parameter accepts wildcards and checks all modules by default.
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
        # Check for required modules and attempt to install if missing.
        try {
            if (-not (Get-Command -Name 'Get-InstalledPSResource' -ErrorAction SilentlyContinue)) {
                Write-Information "The required module 'Microsoft.PowerShell.PSResourceGet' was not found. Attempting to install..." -InformationAction Continue
                try {
                    Install-Module -Name 'Microsoft.PowerShell.PSResourceGet' -Scope CurrentUser -AllowClobber -Force -Verbose:$false
                    Write-Information "Successfully installed 'Microsoft.PowerShell.PSResourceGet'." -InformationAction Continue
                    Import-Module -Name 'Microsoft.PowerShell.PSResourceGet' -Force -Verbose:$false
                } catch {
                    throw "Failed to install and import the required 'Microsoft.PowerShell.PSResourceGet' module. Please install it manually using: Install-Module -Name 'Microsoft.PowerShell.PSResourceGet'"
                }
            } else {
                # Import the module if it's not already imported.
                if (-not (Get-Module -Name 'Microsoft.PowerShell.PSResourceGet')) {
                    Import-Module -Name 'Microsoft.PowerShell.PSResourceGet' -Force -Verbose:$false
                }
            }
        } catch {
            throw "Error checking for required module 'Microsoft.PowerShell.PSResourceGet': $_"
        }

        # Get the AllUsers scope path[s] from PSModulePath. (Re-test on non-Windows platforms.) Ignores blank entries.
        [string[]] $AllUsersModulePaths = @(
            [System.Environment]::GetEnvironmentVariable('PSModulePath', [System.EnvironmentVariableTarget]::Machine) -split [System.IO.Path]::PathSeparator |
            Where-Object { $_ }
        )
        Write-Debug "AllUsers module paths: $($AllUsersModulePaths -join '; ')"

        function Test-IsAllUsersPath {
            # Check if the installed module location is in an AllUsers path.
            param (
                # The ModuleLocation (installation path) of the module to check.
                [Parameter(Mandatory = $true)]
                [string] $ModuleLocation
            )

            # Loop through all AllUsers paths and check if the module location starts with any of them (case-insensitive).
            foreach ($Path in $AllUsersModulePaths) {
                if ($ModuleLocation.StartsWith($Path, [System.StringComparison]::OrdinalIgnoreCase)) {
                    return $true
                }
            }
            return $false
        } # end Test-IsAllUsersPath function

        function Select-ModuleVersion {
            # Take a group of module installations (grouped by name) and select the relevant module version.
            param (
                # A group object containing multiple installations of the same module.
                [Parameter(Mandatory = $true)]
                $ModuleGroup
            )

            # For each module name, prioritize CurrentUser scope over AllUsers scope.
            $CurrentUserModules = @()
            $AllUsersModules = @()

            # Categorize each installed instance of the module by scope (installation location).
            foreach ($Module in $ModuleGroup.Group) {
                if (Test-IsAllUsersPath $Module.InstalledLocation) {
                    $AllUsersModules += $Module
                } else {
                    $CurrentUserModules += $Module
                }
            }

            if ($CurrentUserModules) {
                # If module exists in CurrentUser scope, use the highest version from CurrentUser.
                $SelectedModule = $CurrentUserModules | Sort-Object Version -Descending | Select-Object -First 1
                if ($AllUsersModules) {
                    $HighestAllUsers = $AllUsersModules | Sort-Object Version -Descending | Select-Object -First 1
                    Write-Verbose "Module '$($ModuleGroup.Name)': Using CurrentUser version $($SelectedModule.Version) (AllUsers has $($HighestAllUsers.Version))."
                } else {
                    Write-Verbose "Module '$($ModuleGroup.Name)': Using CurrentUser version $($SelectedModule.Version)."
                }
                return $SelectedModule
            } elseif ($AllUsersModules) {
                # If only in AllUsers scope, use the highest version from AllUsers.
                $SelectedModule = $AllUsersModules | Sort-Object Version -Descending | Select-Object -First 1
                Write-Verbose "Module '$($ModuleGroup.Name)': Using AllUsers version $($SelectedModule.Version) (no CurrentUser installation found)."
                return $SelectedModule
            } else {
                # Fallback: If we can't determine scope, just use the highest version.
                $SelectedModule = $ModuleGroup.Group | Sort-Object Version -Descending | Select-Object -First 1
                Write-Verbose "Module '$($ModuleGroup.Name)': Using highest version $($SelectedModule.Version) (scope undetermined)."
                return $SelectedModule
            }
        } # end SelectBestModuleVersion function

        function Test-IsModulePrerelease {
            # Check if an installed module version is a prerelease version.
            param ($Module, $VersionString)

            # Return true if the IsPrerelease property is true or if the Prerelease property is not empty
            # or if the version string contains a prerelease identifier.
            if ($Module.PSObject.Properties['IsPrerelease']) {
                return $Module.IsPrerelease -or
                (-not [string]::IsNullOrWhiteSpace($Module.Prerelease)) -or
                ($VersionString -match 'alpha|beta|prerelease|preview|rc')
                #-or ($VersionString -match '-')
            } else {
                # Return true if the IsPrerelease property is true or if the Prerelease property is not empty.
                return $Module.IsPrerelease -or (-not [string]::IsNullOrWhiteSpace($Module.Prerelease))
            }
        } # end IsModulePrerelease function

        # Initialize a list to hold modules with updates.
        [System.Collections.Generic.List[PSCustomObject]] $ModulesWithUpdates = @()

    } # end begin block

    process {
        #region Get installed modules
        try {
            # Optimize the search: if no wildcards are used, search for each module specifically
            $HasWildcards = $Name | Where-Object { $_ -match '[*?]' }

            if ($HasWildcards) {
                Write-Host "Searching for installed modules matching patterns: $($Name -join ', ')" -ForegroundColor Cyan
                # Use a wildcard search to get modules and determine if they are installed in an AllUsers or CurrentUser location.
                [System.Collections.Generic.List[PSObject]] $Modules = Get-InstalledPSResource -Name $Name -Verbose:$false |
                    Where-Object { $_.Type -eq 'Module' } | Group-Object -Property 'Name' | ForEach-Object {
                    Select-ModuleVersion $_
                } | Sort-Object Name
            } else {
                # Check each individually for better performance when not using wildcards.
                Write-Host "Searching for specific installed modules: $($Name -join ', ')" -ForegroundColor Cyan
                $AllModules = @()
                foreach ($ModuleName in $Name) {
                    Write-Verbose "Looking for installed module: $ModuleName"
                    $ModuleResults = Get-InstalledPSResource -Name $ModuleName -ErrorAction SilentlyContinue -Verbose:$false |
                        Where-Object { $_.Type -eq 'Module' }
                    if ($ModuleResults) {
                        Write-Verbose "Found $($ModuleResults.Count) installation(s) of module '$ModuleName'."
                        $AllModules += $ModuleResults
                    } else {
                        Write-Verbose "Module '$ModuleName' not found in installed modules."
                    }
                }

                # Group by module name only and select the best version with scope priority
                [System.Collections.Generic.List[PSObject]] $Modules = $AllModules | Group-Object Name |
                    ForEach-Object { Select-ModuleVersion $_ } | Sort-Object Name
            } # end if-else for wildcard check vs explicit name check
        } catch {
            throw $_
        }

        # Stop if no modules were found.
        if (-not $Modules -or $Modules.Count -eq 0) {
            Write-Warning 'No matching modules were found.'
            return
        } else {
            Write-Host "Found $($Modules.Count) installed modules." -ForegroundColor Cyan
        }
        #endregion Get installed modules

        #region Check for updates
        Write-Host 'Checking the source repository for newer versions of the modules...' -ForegroundColor Cyan
        foreach ($Module in $Modules) {

            #region Get module information
            # Check installed [version] and prerelease status [boolean].
            $InstalledVersion = $Module.Version
            $InstalledVersionString = $InstalledVersion.ToString()
            $IsPrerelease = Test-IsModulePrerelease $Module $InstalledVersionString

            # Determine which repository to check based on the module's data.
            $Repository = $null
            if ($Module.Repository -and $Module.Repository -ne 'Unknown') {
                $Repository = $Module.Repository
            } else {
                Write-Verbose "No repository information found for '$($Module.Name)', checking all registered repositories."
            }
            #endregion Get module information

            try {
                # Get the latest online version from the module's original source repository.
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
                    # If the specific repository fails, try without specifying repository.
                        Write-Verbose "Repository-specific search failed for module '$($Module.Name)', trying all repositories with Prerelease:$IsPrerelease"
                        try {
                            $OnlineModule = Find-PSResource -Name $Module.Name -Prerelease:$IsPrerelease
                        } catch {
                            Write-Verbose "All-repository search also failed for '$($Module.Name)'"
                        }

                    # If still no result, re-throw the original error to be handled by the outer catch.
                    if (-not $OnlineModule) {
                        throw
                    }
                }

                # If no online module was found, skip to the next module.
                if (-not $OnlineModule) {
                    Write-Warning "No online version found for module '$($Module.Name)' (Prerelease:$IsPrerelease)."
                    continue
                }

                $OnlineVersion = $OnlineModule.Version

                Write-Verbose "$($Module.Name) $InstalledVersion (Installed)"
                Write-Verbose "$($Module.Name) $OnlineVersion (Online)`n"

                <# Normalize version objects for accurate comparison:
                    PowerShell treats [version]"1.0.0" (Revision=-1) differently from [version]"1.0.0.0" (Revision=0).
                    We need to normalize them by ensuring both have explicit 4-part notation.
                #>

                # Extract the base version without a prerelease suffix (handle both string and version object types).
                $OnlineVersionString = $OnlineVersion.ToString()
                $InstalledVersionString = $InstalledVersion.ToString()

                $OnlineVersionBase = if ($OnlineVersionString -match '^(\d+\.\d+\.\d+(?:\.\d+)?)-') {
                    $matches[1]
                } else {
                    # If it's already a version object without prerelease, just use its string representation.
                    $OnlineVersionString
                }

                $InstalledVersionBase = if ($InstalledVersionString -match '^(\d+\.\d+\.\d+(?:\.\d+)?)-') {
                    $matches[1]
                } else {
                    # If it's already a version object without prerelease, just use its string representation.
                    $InstalledVersionString
                }

                # .NET Version treats -1 as "unspecified", so we need to normalize with all 4 components explicitly defined.
                try {
                    $OnlineVersionObj = [version]$OnlineVersionBase
                    $InstalledVersionObj = [version]$InstalledVersionBase

                    # Build normalized version strings with proper handling of unspecified components.
                    $OnlineBuild       = if ($OnlineVersionObj.Build       -eq -1) { 0 } else { $OnlineVersionObj.Build }
                    $OnlineRevision    = if ($OnlineVersionObj.Revision    -eq -1) { 0 } else { $OnlineVersionObj.Revision }
                    $InstalledBuild    = if ($InstalledVersionObj.Build    -eq -1) { 0 } else { $InstalledVersionObj.Build }
                    $InstalledRevision = if ($InstalledVersionObj.Revision -eq -1) { 0 } else { $InstalledVersionObj.Revision }

                    # Create fully normalized 4-part version objects for accurate comparison.
                    #$OnlineVersionNormalized    = [version]"$($OnlineVersionObj.Major).$($OnlineVersionObj.Minor).$OnlineBuild.$OnlineRevision"
                    #$InstalledVersionNormalized = [version]"$($InstalledVersionObj.Major).$($InstalledVersionObj.Minor).$InstalledBuild.$InstalledRevision"
                    $OnlineVersionNormalized    = [version]"{0}.{1}.{2}.{3}" -f $OnlineVersionObj.Major, $OnlineVersionObj.Minor, $OnlineBuild, $OnlineRevision
                    $InstalledVersionNormalized = [version]"{0}.{1}.{2}.{3}" -f $InstalledVersionObj.Major, $InstalledVersionObj.Minor, $InstalledBuild, $InstalledRevision
                } catch {
                    Write-Warning "Error parsing version for module '$($Module.Name)': Installed='$InstalledVersionString', Online='$OnlineVersionString'. Error: $($_.Exception.Message)"
                    continue
                }

                # Check if the online module is a prerelease version.
                $OnlineIsPrerelease = Test-IsModulePrerelease $OnlineModule $OnlineVersion.ToString()
                Write-Verbose "Normalized versions: Installed=$InstalledVersionNormalized, Online=$OnlineVersionNormalized"
                Write-Verbose "Prerelease status: Installed=$IsPrerelease, Online=$OnlineIsPrerelease"

                # If a newer version is available, create a custom object with the PSPreworkout.ModuleInfo type.
                if ( $OnlineVersionNormalized -gt $InstalledVersionNormalized  -or
                    (
                        # Allow updates from prerelease to stable versions with same or higher base version. This allows upgrading from "1.0.0-beta" to "1.0.0" (stable release).
                        ($OnlineVersionNormalized -ge $InstalledVersionNormalized) -and
                        ($IsPrerelease -and -not $OnlineIsPrerelease)
                    )
                ) {
                    Write-Verbose "$($Module.Name) $($InstalledVersion) --> $($OnlineVersion) 🆕`n"

                    # Create a custom object with PSPreworkout.ModuleInfo type
                    $ModuleInfo = [PSCustomObject]@{
                        PSTypeName            = 'PSPreworkout.ModuleInfo'
                        Name                  = $Module.Name
                        Version               = $InstalledVersion
                        Repository            = $Module.Repository
                        Description           = $Module.Description
                        Author                = $Module.Author
                        CompanyName           = $Module.CompanyName
                        Copyright             = $Module.Copyright
                        PublishedDate         = $Module.PublishedDate
                        InstalledDate         = $Module.InstalledDate
                        UpdateAvailable       = $true
                        OnlineVersion         = $OnlineVersion
                        IsInstalledPrerelease = $IsPrerelease
                        IsOnlinePrerelease    = $OnlineIsPrerelease
                    }
                    # Add the module to the list of modules with updates.
                    $ModulesWithUpdates.Add($ModuleInfo) | Out-Null

                    # Display module information when PassThru is specified.
                    if ($PassThru) {
                        $InstalledVersionDisplay = if ($IsPrerelease) { "$($InstalledVersion) (prerelease)" } else { $InstalledVersion }
                        $OnlineVersionDisplay = if ($OnlineIsPrerelease) { "$($OnlineVersion) (prerelease)" } else { $OnlineVersion }
                        Write-Host "$($Module.Name): $InstalledVersionDisplay → $OnlineVersionDisplay" -ForegroundColor Green
                    }
                }
            } catch {
                # Handle different types of errors more specifically.
                $ErrorMessage = $_.Exception.Message
                if ($ErrorMessage -match 'could not be found') {
                    if ($Repository) {
                        Write-Warning "Module '$($Module.Name)' was not found in repository '$Repository'. It may have been installed manually or from a different source."
                    } else {
                        Write-Warning "Module '$($Module.Name)' was not found in any registered repositories. It may have been installed manually or from an unregistered source."
                    }
                } elseif ($ErrorMessage -match 'null-valued expression') {
                    Write-Warning "Module '$($Module.Name)' search returned null results. This may indicate a repository connectivity issue or the module may not be available in online repositories."
                } else {
                    Write-Warning "Error checking for updates to module '$($Module.Name)': $ErrorMessage"
                }
            }
        }
        #endregion Check for updates

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
