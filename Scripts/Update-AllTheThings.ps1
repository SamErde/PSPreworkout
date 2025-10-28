<#PSScriptInfo
.DESCRIPTION A script to automatically update all PowerShell modules, PowerShell Help, and packages (apt, brew, chocolately, winget).
.VERSION 0.5.8
.GUID 3a1a1ec9-0ef6-4f84-963d-be1505dab6a8
.AUTHOR Sam Erde
.COPYRIGHT (c) 2024 Sam Erde. All rights reserved.
.TAGS Update PowerShell Windows macOS Linux Ubuntu
.LICENSEURI https://github.com/SamErde/PSPreWorkout/blob/main/LICENSE
.PROJECTURI https://github.com/SamErde/PSPreWorkout/
.ICONURI
#>
function Test-IsElevated {
    <#
    .SYNOPSIS
    Check if you are running an elevated shell with administrator or root privileges.

    .DESCRIPTION
    Check if you are running an elevated shell with administrator or root privileges.

    .EXAMPLE
    Test-IsElevated

    .OUTPUTS
    Boolean
    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [Alias('isadmin', 'isroot')]
    param ()

    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
        return $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } else {
        # Must be Linux or OSX, so use the id util. Root has userid of 0.
        return 0 -eq (id -u)
    }
}
function Update-AllTheThings {
    <#
    .SYNOPSIS
    Update all the things!

    .DESCRIPTION
    A script to automatically update all PowerShell modules, PowerShell Help, and packages (apt, brew, chocolately, winget).

    .PARAMETER SkipModules
    Skip the step that updates PowerShell modules.

    .PARAMETER SkipScripts
    Skip the step that updates PowerShell scripts.

    .PARAMETER SkipHelp
    Skip the step that updates PowerShell help.

    .PARAMETER SkipWinGet
    Skip the step the updates WinGet packages.

    .PARAMETER IncludeChocolatey
    Include Chocolatey package updates.

    .PARAMETER AcceptPrompts
    Automatically accept prompts to install updates in Linux (apt, dnf).

    .EXAMPLE
    Update-AllTheThings

    Updates all of the things it can!

    .EXAMPLE
    Update-AllTheThings -AcceptPrompts

    Updates all of the things and automatically accepts Linux package upgrade prompts.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Update-AllTheThings', Justification = 'This is what we do.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive Use')]
    [Alias('uatt')]
    param (
        # Skip the step that updates PowerShell modules
        [Parameter()]
        [switch]
        $SkipModules,

        # Skip the step that updates PowerShell scripts
        [Parameter()]
        [switch]
        $SkipScripts,

        # Skip the step that updates PowerShell help
        [Parameter()]
        [switch]
        $SkipHelp,

        # Skip the step that updates WinGet packages
        [Parameter()]
        [switch]
        $SkipWinGet,

        # Skip the step that updates Chocolatey packages
        [Parameter()]
        [Alias('Skip-Choco')]
        [switch]
        $IncludeChocolatey,

        # Automatically accept prompts to install updates in Linux
        [Parameter()]
        [switch]
        $AcceptPrompts
    )

    begin {
        # Spacing to get host output from script, winget, and choco all below the progress bar.
        $Banner = @"
  __  __        __     __         ___   ____
 / / / /__  ___/ /__ _/ /____    / _ | / / /
/ /_/ / _ \/ _  / _ `/ __/ -_)  / __ |/ / /
\____/ .__/\_,_/\_,_/\__/\__/  /_/ |_/_/_/
 ___/_/__         ________   _
/_  __/ /  ___   /_  __/ /  (_)__  ___ ____
 / / / _ \/ -_)   / / / _ \/ / _ \/ _ `(_-<
/_/ /_//_/\__/   /_/ /_//_/_/_//_/\_, /___/
                                 /___/ 0.5.9

"@
        Write-Host $Banner
    } # end begin block

    process {
        Write-Verbose 'Set the PowerShell Gallery as a trusted installation source.'
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        if (Get-Command -Name Set-PSResourceRepository -ErrorAction SilentlyContinue) {
            Set-PSResourceRepository -Name 'PSGallery' -Trusted
        }

        #region UpdatePowerShell

        # ==================== Update PowerShell Modules ====================

        # Update the outer progress bar
        $PercentCompleteOuter = 1
        $ProgressParamOuter = @{
            Id               = 0
            Activity         = 'Update Everything'
            CurrentOperation = 'Getting Installed PowerShell Modules'
            Status           = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete  = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter

        if (-not $SkipModules) {
            # Get all installed PowerShell modules
            Write-Host '[1] Getting Installed PowerShell Modules'
            $Modules = (Get-InstalledModule)
            $ModuleCount = $Modules.Count
            Write-Host "[2] Updating $ModuleCount PowerShell Modules"
        } else {
            Write-Host '[1] Skipping PowerShell Modules'
        }

        # Estimate 10% progress so far and 70% at the next step
        $PercentCompleteOuter_Modules = 10
        [int]$Module_i = 0

        # Update all PowerShell modules
        foreach ($module in $Modules) {
            # Update the module loop counter and percent complete for both progress bars
            ++$Module_i
            [double]$PercentCompleteInner = [math]::ceiling( (($Module_i / $ModuleCount) * 100) )
            [double]$PercentCompleteOuter = [math]::ceiling( $PercentCompleteOuter_Modules + (60 * ($PercentCompleteInner / 100)) )

            # Update the outer progress bar while updating modules
            $ProgressParamOuter = @{
                Id              = 0
                Activity        = 'Update Everything'
                Status          = "Progress: $PercentCompleteOuter`% Complete"
                PercentComplete = $PercentCompleteOuter
            }
            Write-Progress @ProgressParamOuter

            # Update the child progress bar while updating modules
            $ProgressParam1 = @{
                Id               = 1
                ParentId         = 0
                Activity         = 'Updating PowerShell Modules'
                CurrentOperation = "$($module.Name)"
                Status           = "Progress: $PercentCompleteInner`% Complete"
                PercentComplete  = $PercentCompleteInner
            }
            Write-Progress @ProgressParam1

            # Do not update prerelease modules
            if ($module.Version -match 'alpha|beta|prerelease|preview') {
                Write-Information "`t`tSkipping $($module.Name) because a prerelease version is currently installed." -InformationAction Continue
                continue
            }

            # Finally update the current module
            try {
                Update-Module $module.Name
            } catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                # Add a catch for mismatched certificates between module versions.
                Write-Verbose $_
            }
        }

        # ##### Add a section for installed scripts +++++
        if (-not $SkipScripts) {
            Write-Host '[2] Updating PowerShell Scripts'
            Update-Script
        } else {
            Write-Host '[2] Skipping PowerShell Scripts'
        }
        # ##### Add a section for installed scripts +++++

        # Complete the child progress bar after updating modules
        Write-Progress -Id 1 -Activity 'Updating PowerShell Modules' -Completed


        # ==================== Update PowerShell Help ====================

        # Update the outer progress bar while updating help
        $PercentCompleteOuter = 70
        $ProgressParamOuter = @{
            Id               = 0
            Activity         = 'Update Everything'
            CurrentOperation = 'Updating PowerShell Help'
            Status           = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete  = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter

        if (-not $SkipHelp) {
            Write-Host '[3] Updating PowerShell Help'
            # Fixes error with culture ID 127 (Invariant Country), which is not associated with any language
            if ((Get-Culture).LCID -eq 127) {
                Update-Help -UICulture en-US -ErrorAction SilentlyContinue
            } else {
                Update-Help -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host '[3] Skipping PowerShell Help'
        }
        #endregion UpdatePowerShell

        #region UpdateWinget
        # >>> Create a section to check OS and client/server OS at the top of the script <<< #
        if ($IsWindows -or ($PSVersionTable.PSVersion -le [version]'5.1')) {

            if ((Get-CimInstance -ClassName CIM_OperatingSystem).Caption -match 'Server') {
                # If on Windows Server, prompt to continue before automatically updating packages.
                Write-Warning -Message 'This is a server and updates could affect production systems. Do you want to continue with updating packages?'

                $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Description.'
                $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Description.'
                $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)

                $Title = 'Windows Server OS Found'
                $Message = "Do you want to run 'winget update' on your server?"
                $Result = $Host.UI.PromptForChoice($Title, $Message, $Options, 1)
                switch ($Result) {
                    0 {
                        continue
                    }
                    1 {
                        $SkipWinGet = $true
                    }
                }
            }

            if (-not $SkipWinGet) {
                # Update all winget packages
                Write-Host '[4] Updating Winget Packages'
                # Update the outer progress bar for winget section
                $PercentCompleteOuter = 80
                $ProgressParamOuter = @{
                    Id               = 0
                    Activity         = 'Update Everything'
                    CurrentOperation = 'Updating Winget Packages'
                    Status           = "Progress: $PercentCompleteOuter`% Complete"
                    PercentComplete  = $PercentCompleteOuter
                }
                Write-Progress @ProgressParamOuter
                if (Get-Command winget -ErrorAction SilentlyContinue) {
                    winget upgrade --silent --scope user --accept-package-agreements --accept-source-agreements --all
                } else {
                    Write-Host '[4] WinGet was not found. Skipping WinGet update.'
                }
            } else {
                Write-Host '[3] Skipping WinGet'
                continue
            }
        } else {
            Write-Verbose '[4] Not Windows. Skipping WinGet.'
        }
        #endregion UpdateWinget

        #region UpdateLinuxPackages
        # Early testing. No progress bar yet. Need to check for admin, different distros, and different package managers.
        if ($IsLinux) {
            if (Get-Command apt -ErrorAction SilentlyContinue) {
                Write-Host '[5] Updating apt packages.'
                sudo apt update
                if ($AcceptPrompts) {
                    sudo apt upgrade -y
                } else {
                    sudo apt upgrade
                }
            }
            if (Get-Command dnf -ErrorAction SilentlyContinue) {
                Write-Host '[5] Updating dnf packages.'
                if ($AcceptPrompts) {
                    sudo dnf update -y
                } else {
                    sudo dnf update
                }
            }
        } else {
            Write-Verbose '[5] Not Linux. Skipping section.'
        }
        #endregion UpdateLinuxPackages

        #region UpdateMacOS
        # Early testing. No progress bar yet. Need to check for admin and different package managers.
        if ($IsMacOS) {
            softwareupdate -l
            if (Get-Command brew -ErrorAction SilentlyContinue) {
                Write-Host '[6] Updating brew packages.'
                brew update
                brew upgrade
            }
        } else {
            Write-Verbose '[6] Not macOS. Skipping section.'
        }
        #endregion UpdateMacOS

        #region UpdateChocolatey
        # Upgrade Chocolatey packages. Need to check for admin to avoid errors/warnings.
        if ((Get-Command choco -ErrorAction SilentlyContinue) -and $IncludeChocolatey) {
            # Update the outer progress bar
            $PercentCompleteOuter = 90
            $ProgressParamOuter = @{
                Id               = 0
                Activity         = 'Update Everything'
                CurrentOperation = 'Updating Chocolatey Packages'
                Status           = "Progress: $PercentCompleteOuter`% Complete"
                PercentComplete  = $PercentCompleteOuter
            }
            Write-Progress @ProgressParamOuter
            Write-Host '[7] Updating Chocolatey Packages'
            # Add a function/parameter to run these two feature configuration options, which requires admin to set.
            if (Test-IsElevated) {
                # Oops, this depends on PSPreworkout being installed or that function otherwise being available.
                choco feature enable -n=allowGlobalConfirmation
                choco feature disable --name=showNonElevatedWarnings
            } else {
                Write-Verbose "Run once as an administrator to disable Chocoately's showNonElevatedWarnings." -Verbose
            }
            choco upgrade chocolatey -y --limit-output --accept-license --no-color
            choco upgrade all -y --limit-output --accept-license --no-color
            # Padding to reset host before updating the progress bar.
            Write-Host ' '
        } else {
            Write-Host '[7] Skipping Chocolatey'
        }
        #endregion UpdateChocolatey

    } # end process block

    end {
        Write-Host 'Done.'
        # Update the outer progress bar
        $PercentCompleteOuter = 100
        $ProgressParamOuter = @{
            Id               = 0
            Activity         = 'Update Everything'
            CurrentOperation = 'Finished'
            Status           = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete  = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter
        # Complete the outer progress bar
        Write-Progress -Id 0 -Activity 'Update Everything' -Completed
    }

}
