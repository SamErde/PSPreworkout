<#PSScriptInfo
.VERSION 0.3.0
.GUID 3a1a1ec9-0ef6-4f84-963d-be1505dab6a8
.AUTHOR Sam Erde
.COPYRIGHT (c) Sam Erde
.TAGS Update PowerShell Windows Linux macOS
.LICENSEURI
.PROJECTURI https://github.com/SamErde
.ICONURI
#>

function Update-AllTheThings {
    <#
    .SYNOPSIS
    Update-AllTheThings: Update all the things!

    .DESCRIPTION
    A script to automatically update all PowerShell modules, PowerShell Help, and packages (apt, brew, chocolately, winget).

    .EXAMPLE
    PS> Update-AllTheThings

    Updates all of the things it can!

    .INPUTS
    None. You can't pipe objects to Update-Everything.

    .OUTPUTS
    None. Update-Everything does not return any objects.

    .LINK
    GitHub Repository: https://github.com/SamErde/Chocolatey-Dip
    Twitter / X: https://twitter.com/SamErde

    .NOTES
    Author: Sam Erde
    Version: 0.2.1
    Modified: 2024/07/22

    Ideas to do:
        - Check for Windows or Linux
        - Check for elevation/admin rights
        - Update PowerShell
        - Update Linux packages
    #>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive Use')]
    [Alias("Update-Everything,","UATT")]
    param ()

    # Spacing to get host output from script, winget, and choco all below the progress bar.
    Write-Host @'
  __  __        __     __         ___   ____
 / / / /__  ___/ /__ _/ /____    / _ | / / /
/ /_/ / _ \/ _  / _ `/ __/ -_)  / __ |/ / /
\____/ .__/\_,_/\_,_/\__/\__/  /_/ |_/_/_/
 ___/_/__         ________   _
/_  __/ /  ___   /_  __/ /  (_)__  ___ ____
 / / / _ \/ -_)   / / / _ \/ / _ \/ _ `(_-<
/_/ /_//_/\__/   /_/ /_//_/_/_//_/\_, /___/
                                 /___/

'@
    # Get all installed PowerShell modules
    Write-Host "[1] Getting Installed PowerShell Modules"
    # Update the outer progress bar
    $PercentCompleteOuter = 1
    $ProgressParamOuter = @{
        Id = 0
        Activity = 'Update Everything'
        CurrentOperation = 'Getting Installed PowerShell Modules'
        Status = "Progress: $PercentCompleteOuter`% Complete"
        PercentComplete = $PercentCompleteOuter
    }
    Write-Progress @ProgressParamOuter
    $Modules = (Get-InstalledModule)[0..15]
    $ModuleCount = $Modules.Count


    # Update all PowerShell modules
    Write-Host "[2] Updating $ModuleCount PowerShell Modules"
    # Estimate 10% progress so far and 70% at the next step
    $PercentCompleteOuter_Modules = 10
    [int]$Module_i = 0

    foreach ($module in $Modules) {
        # Update the module loop counter and percent complete for both progress bars
        ++$Module_i
        [double]$PercentCompleteInner = [math]::ceiling( (($Module_i / $ModuleCount)*100) )
        [double]$PercentCompleteOuter = [math]::ceiling( $PercentCompleteOuter_Modules + (60*($PercentCompleteInner/100)) )

        # Update the outer progress bar
        $ProgressParamOuter = @{
            Id = 0
            Activity = 'Update Everything'
            Status = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter

        # Update the child progress bar
        $ProgressParam1 = @{
            Id = 1
            ParentId = 0
            Activity = 'Updating PowerShell Modules'
            CurrentOperation = "$($module.Name)"
            Status = "Progress: $PercentCompleteInner`% Complete"
            PercentComplete = $PercentCompleteInner
        }
        Write-Progress @ProgressParam1

        # Update the current module
        try {
            Update-Module $ -ErrorAction SilentlyContinue
        } catch [Microsoft.PowerShell.Commands.WriteErrorException] {
            Write-Verbose $_
        }
    }
    # Complete the child progress bar
    Write-Progress -Id 1 -Activity 'Updating PowerShell Modules' -Completed


    # Update PowerShell Help
    Write-Host "[3] Updating PowerShell Help"
    # Update the outer progress bar
    $PercentCompleteOuter = 70
    $ProgressParamOuter = @{
        Id = 0
        Activity = 'Update Everything'
        CurrentOperation = 'Updating PowerShell Help'
        Status = "Progress: $PercentCompleteOuter`% Complete"
        PercentComplete = $PercentCompleteOuter
    }
    Write-Progress @ProgressParamOuter
    # Fixes error with culture ID 127 (Invariant Country), which is not associated with any language
    if ((Get-Culture).LCID -eq 127) {
        Update-Help -UICulture en-US -ErrorAction SilentlyContinue
    } else {
        Update-Help -ErrorAction SilentlyContinue
    }

    if ($IsWindows -or ($PSVersionTable.PSVersion -like "5.1.*")) {
        # Update all winget packages
        Write-Host "[4] Updating Winget Packages"
        # Update the outer progress bar
        $PercentCompleteOuter = 80
        $ProgressParamOuter = @{
            Id = 0
            Activity = 'Update Everything'
            CurrentOperation = 'Updating Winget Packages'
            Status = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter
        <# Check for Windows and/or winget.exe
        if () { }
        #>
        winget upgrade --silent --scope user --accept-package-agreements --accept-source-agreements --all
    }

    # Early testing. No progress bar yet. Need to check for admin, different distros, and different package managers.
    if ($IsLinux) {
        if (Get-Command apt -ErrorAction SilentlyContinue) {
            Write-Host '[6] Updating apt packages.'
            sudo apt update
            sudo apt upgrade
        }
    }

    # Early testing. No progress bar yet. Need to check for admin and different package managers.
    if ($IsMacOS) {
        softwareupdate -l
        if (Get-Command brew -ErrorAction SilentlyContinue) {
            Write-Host '[7] Updating brew packages.'
            brew update
            brew upgrade
        }
    }

    # Upgrade Chocolatey packages. Need to check for admin.
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        # Update the outer progress bar
        $PercentCompleteOuter = 90
        $ProgressParamOuter = @{
            Id = 0
            Activity = 'Update Everything'
            CurrentOperation = 'Updating Chocolatey Packages'
            Status = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter
        Write-Host "[5] Updating Chocolatey Packages"
        choco upgrade chocolatey --limitoutput --yes
        choco upgrade all --limitoutput --yes
    } else {
        Write-Host "[5] Chocolatey is not installed. Skipping choco update."
    }


    # Update the outer progress bar
    $PercentCompleteOuter = 100
    $ProgressParamOuter = @{
        Id = 0
        Activity = 'Update Everything'
        CurrentOperation = 'Finished'
        Status = "Progress: $PercentCompleteOuter`% Complete"
        PercentComplete = $PercentCompleteOuter
    }
    Write-Progress @ProgressParamOuter
    # Complete the outer progress bar
    Write-Progress -Id 0 -Activity 'Update Everything' -Completed

}
