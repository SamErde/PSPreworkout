function Update-AllTheThings {
    <#
    .SYNOPSIS
    Update all the things!

    .DESCRIPTION
    A script to automatically update all PowerShell modules, PowerShell Help, GitHub CLI extensions, GitHub Copilot CLI, and packages (apt, brew, Chocolatey, WinGet).

    .PARAMETER SkipModules
    Skip the step that updates PowerShell modules.

    .PARAMETER SkipScripts
    Skip the step that updates PowerShell scripts.

    .PARAMETER SkipHelp
    Skip the step that updates PowerShell help.

    .PARAMETER SkipWinGet
    Skip the step that updates WinGet packages.

    .PARAMETER IncludeChocolatey
    Include Chocolatey package updates.

    .PARAMETER AcceptPrompts
    Automatically accept prompts to install updates in Linux (apt, dnf) and continue WinGet updates on Windows Server without showing the extra server confirmation prompt.

    .EXAMPLE
    Update-AllTheThings

    Updates all of the things it can!

    .EXAMPLE
    Update-AllTheThings -AcceptPrompts

    Updates all of the things and automatically accepts Linux package upgrade prompts and the additional WinGet confirmation prompt on Windows Server.

    .NOTES
    Author: Sam Erde
    Version: 0.6.0
    #>

    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Medium',
        HelpUri = 'https://day3bits.com/PSPreworkout/Update-AllTheThings'
    )]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This is what we do.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive Use')]
    [Alias('uatt')]
    param (
        # Skip the step that updates PowerShell modules
        [Parameter()]
        [switch]$SkipModules,

        # Skip the step that updates PowerShell scripts
        [Parameter()]
        [switch]$SkipScripts,

        # Skip the step that updates PowerShell help
        [Parameter()]
        [switch]$SkipHelp,

        # Skip the step that updates WinGet packages
        [Parameter()]
        [switch]$SkipWinGet,

        # Include Chocolatey package updates
        [Parameter()]
        [Alias('SkipChoco')]
        [switch]$IncludeChocolatey,

        # Automatically accept prompts to install updates
        [Parameter()]
        [switch]$AcceptPrompts
    )

    begin {
        if (Test-PSPreworkoutCommand -Name 'Write-PSPreworkoutTelemetry') {
            Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys
        }

        $Banner = @"
  __  __        __     __         ___   ____
 / / / /__  ___/ /__ _/ /____    / _ | / / /
/ /_/ / _ \/ _  / _ `/ __/ -_)  / __ |/ / /
\____/ .__/\_,_/\_,_/\__/\__/  /_/ |_/_/_/
 ___/_/__         ________   _
/_  __/ /  ___   /_  __/ /  (_)__  ___ ____
 / / / _ \/ -_)   / / / _ \/ / _ \/ _ `(_-<
/_/ /_//_/\__/   /_/ /_//_/_/_//_/\_, /___/
                                 /___/ v0.6.0

"@
        Write-Host $Banner
    }

    process {
        $CommonParameters = @{}
        foreach ($CommonParameterName in 'WhatIf', 'Confirm') {
            if ($PSBoundParameters.ContainsKey($CommonParameterName)) {
                $CommonParameters[$CommonParameterName] = $PSBoundParameters[$CommonParameterName]
            }
        }

        $Platform = Get-PSPreworkoutPlatform

        Set-UpdateRepositoryTrust @CommonParameters
        Update-PowerShellArtifact -SkipModules:$SkipModules -SkipScripts:$SkipScripts -SkipHelp:$SkipHelp @CommonParameters

        if ($Platform -eq 'Windows') {
            Update-WinGetPackage -Skip:$SkipWinGet -AcceptPrompts:$AcceptPrompts @CommonParameters
        } else {
            Write-Verbose '[4] Not Windows. Skipping WinGet.'
        }

        if ($Platform -eq 'Linux') {
            Update-LinuxPackage -AcceptPrompts:$AcceptPrompts @CommonParameters
        } else {
            Write-Verbose '[5] Not Linux. Skipping section.'
        }

        if ($Platform -eq 'macOS') {
            Update-MacOSPackage @CommonParameters
        } else {
            Write-Verbose '[6] Not macOS. Skipping section.'
        }

        $OptionalCliUpdates = @(
            @{
                CommandName      = 'gh'
                DisplayName      = '[7] Updating GitHub CLI Extensions'
                CurrentOperation = 'Updating GitHub CLI Extensions'
                TargetName       = 'GitHub CLI extensions'
                ActionName       = 'Upgrade all installed extensions'
                PercentComplete  = 90
                UpdateCommand    = { Invoke-GitHubCliExtensionUpgrade }
            }
            @{
                CommandName      = 'copilot'
                DisplayName      = '[8] Updating GitHub Copilot CLI'
                CurrentOperation = 'Updating GitHub Copilot CLI'
                TargetName       = 'GitHub Copilot CLI'
                ActionName       = 'Update installed CLI'
                PercentComplete  = 95
                UpdateCommand    = { Invoke-GitHubCopilotCliUpdate }
            }
        )

        foreach ($CliUpdate in $OptionalCliUpdates) {
            Update-OptionalCli @CliUpdate @CommonParameters
        }

        Update-ChocolateyPackage -Include:$IncludeChocolatey @CommonParameters
    }

    end {
        Write-Host 'Done.'
        Write-UpdateAllTheThingsProgress -CurrentOperation 'Finished' -PercentComplete 100
        Write-UpdateAllTheThingsProgress -Completed
    }
}
