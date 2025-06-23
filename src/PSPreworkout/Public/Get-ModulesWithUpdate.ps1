function Get-ModulesWithUpdate {
    <#
    .SYNOPSIS
    Get a list of installed PowerShell modules that have updates available in the PowerShell Gallery.

    .DESCRIPTION
    This function retrieves a list of installed PowerShell modules and checks for updates available in the source repository.

    .PARAMETER Name
    The module name or list of module names to check for updates. Wildcards are allowed, and all modules are checked by default.

    .EXAMPLE
    Get-ModulesWithUpdate
    This command retrieves all installed PowerShell modules and checks for updates available in the PowerShell Gallery.

    .NOTES
    To Do:
    - Batch and "paginate" online checks to speed up. Find-Module can return up to 63 results in one request.
    - Add support for checking other repositories.

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
            HelpMessage = 'Enter a module name or names. Wildcards are allowed.'
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [System.Collections.Generic.List[string]] $Name = @('*')
    )

    begin {
        # Initialize a list to hold modules with updates.
        [System.Collections.Generic.List[System.Object]] $ModulesWithUpdates = @()
    } # end begin block

    process {
        # Get installed modules.
        Write-Host -ForegroundColor Cyan "Getting installed modules ($($Name -join ', '))..."
        try {
            [System.Collections.Generic.List[System.Object]] $Modules = Get-InstalledModule -Name $Name | Sort-Object Name
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

            # Use $true for the AllowPrerelease argument if the module version string contains 'beta', 'prerelease', 'preview', or 'rc'.
            $IsPrerelease = ( $InstalledVersion -match 'beta|prerelease|preview|rc' )
            if ($IsPrerelease) {
                $Prerelease = '-' + ($InstalledVersion -split '-')[1]
            } else {
                $Prerelease = '~~NA~~'
            }

            try {
                # Get the latest online version. Only check pre-release versions if a pre-release version is already installed.
                $OnlineModule = Find-Module -Name $Module.Name -AllowPrerelease:$IsPrerelease
                $OnlineVersion = $OnlineModule.Version
                # Find-PSResource -Name Maester -Version 1.1.16-preview -Prerelease
                # The Get-PSResource cmdlet provides Repository name and can be optimized to check other repositories if needed.

                Write-Verbose "$($Module.Name) $InstalledVersion (Installed)"
                Write-Verbose "$($Module.Name) $OnlineVersion (Online)"

                # If a newer version is available, create a custom object with PSPreworkout.ModuleInfo type.
                if (
                    (
                        # Compare the version numbers while ignoring the pre-release suffix.
                        # Treat the installed version as an array in case multiple versions are installed.
                        [version]$OnlineVersion.Replace($Prerelease, '') -gt @([version]$InstalledVersion.Replace($Prerelease, ''))[0]
                    ) -or
                    (
                        # Check if the version numbers are equal, but the installed version is a pre-release version and the online version is not.
                        # This allows updates from prerelease to stable versions.
                        ( [version]$OnlineVersion.Replace($Prerelease, '') -ge @([version]($InstalledVersion).Replace($Prerelease, ''))[0] ) -and
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
                    }                    # Add the module to the list of modules with updates.
                    $ModulesWithUpdates.Add($ModuleInfo) | Out-Null
                }
            } catch {
                # Show a warning if the module is not found in the online repository.
                Write-Warning "Module $($Module.Name) was not found in the online repository. $_"
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
