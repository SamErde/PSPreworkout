<#PSScriptInfo
.DESCRIPTION A script to automatically update all PowerShell modules, PowerShell Help, GitHub CLI extensions, GitHub Copilot CLI, and packages (apt, brew, Chocolatey, winget).
.VERSION 0.5.10
.GUID 3a1a1ec9-0ef6-4f84-963d-be1505dab6a8
.AUTHOR Sam Erde
.COPYRIGHT (c) 2024 Sam Erde. All rights reserved.
.TAGS Update PowerShell Windows macOS Linux Ubuntu
.LICENSEURI https://github.com/SamErde/PSPreWorkout/blob/main/LICENSE
.PROJECTURI https://github.com/SamErde/PSPreWorkout/
.ICONURI
#>

function Test-PSPreworkoutCommand {
    <#
    .SYNOPSIS
    Tests whether a command is available.

    .DESCRIPTION
    Resolves a command without emitting an error and returns whether it was found.

    .PARAMETER Name
    The name of the command to resolve.

    .OUTPUTS
    System.Boolean
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Get-PSPreworkoutPlatform {
    <#
    .SYNOPSIS
    Gets the current operating-system platform.

    .DESCRIPTION
    Returns a stable platform name across Windows PowerShell 5.1 and PowerShell 7.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        return 'Windows'
    }

    if (Get-Variable -Name IsWindows -ValueOnly -ErrorAction SilentlyContinue) {
        return 'Windows'
    }

    if (Get-Variable -Name IsLinux -ValueOnly -ErrorAction SilentlyContinue) {
        return 'Linux'
    }

    if (Get-Variable -Name IsMacOS -ValueOnly -ErrorAction SilentlyContinue) {
        return 'macOS'
    }

    return 'Unknown'
}

function Get-CimOperatingSystemCaption {
    <#
    .SYNOPSIS
    Gets the operating-system caption through CIM.

    .DESCRIPTION
    Queries CIM_OperatingSystem and returns its caption.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Query = {
            (Get-CimInstance -ClassName CIM_OperatingSystem -ErrorAction Stop).Caption
        }
    )

    return & $Query
}

function Get-WmiOperatingSystemCaption {
    <#
    .SYNOPSIS
    Gets the operating-system caption through WMI.

    .DESCRIPTION
    Queries Win32_OperatingSystem and returns its caption for Windows PowerShell
    5.1 environments where CimCmdlets are unavailable.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWMICmdlet',
        '',
        Justification = 'Get-WmiObject is required as a Windows PowerShell 5.1 fallback when CimCmdlets are unavailable.'
    )]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Query = {
            (Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop).Caption
        }
    )

    return & $Query
}

function Get-WindowsOperatingSystemCaption {
    <#
    .SYNOPSIS
    Gets the Windows operating-system caption.

    .DESCRIPTION
    Uses CIM when available and falls back to WMI for Windows PowerShell 5.1
    environments where the CimCmdlets module is unavailable.

    .OUTPUTS
    System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (Test-PSPreworkoutCommand -Name 'Get-CimInstance') {
        try {
            return Get-CimOperatingSystemCaption
        } catch {
            Write-Verbose 'Get-CimInstance failed while checking the Windows operating system caption.'
        }
    }

    if (Test-PSPreworkoutCommand -Name 'Get-WmiObject') {
        try {
            return Get-WmiOperatingSystemCaption
        } catch {
            Write-Verbose 'Get-WmiObject failed while checking the Windows operating system caption.'
        }
    }
}

function Read-WinGetServerChoice {
    <#
    .SYNOPSIS
    Prompts before updating packages on Windows Server.

    .DESCRIPTION
    Shows a host choice prompt that defaults to declining WinGet package updates.

    .OUTPUTS
    System.Int32
    #>

    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [object]$HostUserInterface = $Host.UI
    )

    $Options = [System.Management.Automation.Host.ChoiceDescription[]]@(
        [System.Management.Automation.Host.ChoiceDescription]::new('&Yes', 'Continue with WinGet package updates.')
        [System.Management.Automation.Host.ChoiceDescription]::new('&No', 'Skip WinGet package updates.')
    )

    return $HostUserInterface.PromptForChoice(
        'Windows Server OS Found',
        "Do you want to run 'winget upgrade' on your server?",
        $Options,
        1
    )
}

function Invoke-WinGetUpgrade {
    <#
    .SYNOPSIS
    Upgrades all user-scoped WinGet packages.

    .DESCRIPTION
    Invokes WinGet non-interactively and throws when WinGet reports a failure.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            & winget upgrade --silent --scope user --accept-package-agreements --accept-source-agreements --all |
                Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command
    if ($ExitCode -ne 0) {
        throw "WinGet package upgrade failed with exit code $ExitCode."
    }
}

function Invoke-GitHubCliExtensionUpgrade {
    <#
    .SYNOPSIS
    Upgrades installed GitHub CLI extensions.

    .DESCRIPTION
    Invokes the GitHub CLI extension upgrade command and throws when it fails.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            & gh extension upgrade --all | Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command
    if ($ExitCode -ne 0) {
        throw "GitHub CLI extension upgrade failed with exit code $ExitCode."
    }
}

function Invoke-GitHubCopilotCliUpdate {
    <#
    .SYNOPSIS
    Updates the GitHub Copilot CLI.

    .DESCRIPTION
    Invokes the GitHub Copilot CLI update command and throws when it fails.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            & copilot update | Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command
    if ($ExitCode -ne 0) {
        throw "GitHub Copilot CLI update failed with exit code $ExitCode."
    }
}

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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Test-IsElevated')]
    [Alias('isadmin', 'isroot')]
    [OutputType([bool])]
    param ()

    # The standalone Update-AllTheThings script does not include module telemetry.
    if (Get-Command -Name Write-PSPreworkoutTelemetry -CommandType Function -ErrorAction SilentlyContinue) {
        Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys
    }

    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
        return $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } else {
        # Unix-like systems (Linux, macOS, etc.)
        # Method 1: Try id command with error handling
        try {
            $userId = & id -u 2>$null
            if ($LASTEXITCODE -eq 0 -and $null -ne $userId) {
                return 0 -eq [int]$userId
            }
        } catch {
            Write-Debug "id command failed: $($_.Exception.Message)"
        }

        # Method 2: Check username via .NET
        try {
            if ([System.Environment]::UserName -eq 'root') {
                return $true
            }
        } catch {
            Write-Debug ".NET username check failed: $($_.Exception.Message)"
        }

        # Method 3: Check for macOS admin group membership
        try {
            # Check if we're on macOS and if user is in admin or wheel groups
            if ($IsMacOS -or (Get-Command 'sw_vers' -ErrorAction SilentlyContinue)) {
                # Method 3a: Use groups command to check admin group membership
                $groups = & groups 2>$null
                if ($LASTEXITCODE -eq 0 -and $groups) {
                    $groupList = $groups -split '\s+'
                    if ($groupList -contains 'admin' -or $groupList -contains 'wheel') {
                        return $true
                    }
                }

                # Method 3b: Use id command to check group IDs
                $groupIds = & id -G 2>$null
                if ($LASTEXITCODE -eq 0 -and $groupIds) {
                    $gidList = $groupIds -split '\s+' | ForEach-Object { [int]$_ }
                    if ($gidList -contains 80 -or $gidList -contains 0) {
                        # 80=admin, 0=wheel
                        return $true
                    }
                }
            }
        } catch {
            Write-Debug "macOS admin group check failed: $($_.Exception.Message)"
        }

        # Method 4: Check effective user ID via /proc (Linux-specific)
        try {
            if (Test-Path '/proc/self/status') {
                $statusContent = Get-Content '/proc/self/status' -ErrorAction SilentlyContinue
                $uidLine = $statusContent | Where-Object { $_ -match '^Uid:' }
                if ($uidLine -and $uidLine -match '\s+(\d+)\s+') {
                    return 0 -eq [int]$matches[1]
                }
            }
        } catch {
            Write-Debug "/proc status check failed: $($_.Exception.Message)"
        }

        # All methods failed
        Write-Warning 'Unable to determine elevation status on this Unix-like system. All detection methods failed.'
        return $false
    }
}

function Update-AllTheThings {
    <#
    .SYNOPSIS
    Update all the things!

    .DESCRIPTION
    A script to automatically update all PowerShell modules, PowerShell Help, GitHub CLI extensions, GitHub Copilot CLI, and packages (apt, brew, Chocolatey, winget).

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
    Automatically accept prompts to install updates in Linux (apt, dnf) and continue WinGet updates on Windows Server without showing the extra server confirmation prompt.

    .EXAMPLE
    Update-AllTheThings

    Updates all of the things it can!

    .EXAMPLE
    Update-AllTheThings -AcceptPrompts

    Updates all of the things and automatically accepts Linux package upgrade prompts and the additional WinGet confirmation prompt on Windows Server.

    .NOTES
    Author: Sam Erde
    Version: 0.5.10
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
        [Alias('SkipChoco')]
        [switch]
        $IncludeChocolatey,

        # Automatically accept prompts to install updates in Linux
        [Parameter()]
        [switch]
        $AcceptPrompts
    )

    begin {
        # Send non-identifying usage statistics to PostHog when the helper is available.
        if (Test-PSPreworkoutCommand -Name 'Write-PSPreworkoutTelemetry') {
            Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys
        }

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
                                 /___/ v0.5.10

"@
        Write-Host $Banner
    } # end begin block

    process {
        $Platform = Get-PSPreworkoutPlatform

        Write-Verbose 'Set the PowerShell Gallery as a trusted installation source.'
        if (
            (Test-PSPreworkoutCommand -Name 'Set-PSRepository') -and
            $PSCmdlet.ShouldProcess('PSGallery', 'Set PowerShellGet repository as trusted')
        ) {
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        }
        if (Test-PSPreworkoutCommand -Name 'Set-PSResourceRepository') {
            if ($PSCmdlet.ShouldProcess('PSGallery', 'Set PSResourceGet repository as trusted')) {
                Set-PSResourceRepository -Name 'PSGallery' -Trusted
            }
        }

        $InvokeOptionalCliUpdate = {
            param(
                [Parameter(Mandatory)]
                [string]$CommandName,

                [Parameter(Mandatory)]
                [string]$DisplayName,

                [Parameter(Mandatory)]
                [string]$CurrentOperation,

                [Parameter(Mandatory)]
                [string]$TargetName,

                [Parameter(Mandatory)]
                [string]$ActionName,

                [Parameter(Mandatory)]
                [int]$PercentComplete,

                [Parameter(Mandatory)]
                [scriptblock]$UpdateCommand
            )

            if (Test-PSPreworkoutCommand -Name $CommandName) {
                Write-Host $DisplayName
                $ProgressParamOuter = @{
                    Id               = 0
                    Activity         = 'Update Everything'
                    CurrentOperation = $CurrentOperation
                    Status           = "Progress: $PercentComplete`% Complete"
                    PercentComplete  = $PercentComplete
                }
                Write-Progress @ProgressParamOuter
                if ($PSCmdlet.ShouldProcess($TargetName, $ActionName)) {
                    & $UpdateCommand
                }
            } else {
                Write-Verbose "$DisplayName was skipped because $CommandName was not found."
            }
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
                if ($PSCmdlet.ShouldProcess($module.Name, 'Update PowerShell module')) {
                    Update-Module $module.Name
                }
            } catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                # Add a catch for mismatched certificates between module versions.
                Write-Verbose $_
            }
        }

        # ##### Add a section for installed scripts +++++
        if (-not $SkipScripts) {
            Write-Host '[2] Updating PowerShell Scripts'
            if ($PSCmdlet.ShouldProcess('Installed PowerShell scripts', 'Update scripts')) {
                Update-Script
            }
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
            if ($PSCmdlet.ShouldProcess('PowerShell help files', 'Update help')) {
                if ((Get-Culture).LCID -eq 127) {
                    Update-Help -UICulture en-US -ErrorAction SilentlyContinue
                } else {
                    Update-Help -ErrorAction SilentlyContinue
                }
            }
        } else {
            Write-Host '[3] Skipping PowerShell Help'
        }
        #endregion UpdatePowerShell

        #region UpdateWinget
        # >>> Create a section to check OS and client/server OS at the top of the script <<< #
        if ($Platform -eq 'Windows') {
            $WinGetAvailable = Test-PSPreworkoutCommand -Name 'winget'
            $WindowsOsCaption = $null
            $ShouldUpdateWinGet = $false
            $SkipServerPrompt = $AcceptPrompts -or $WhatIfPreference -or ($PSBoundParameters.ContainsKey('Confirm') -and (-not $Confirm))
            $ShouldProcessHandlesConsent = ($PSBoundParameters.ContainsKey('Confirm') -and $Confirm) -or (
                ($ConfirmPreference -ne [System.Management.Automation.ConfirmImpact]::None) -and
                (([System.Management.Automation.ConfirmImpact]$ConfirmPreference) -le [System.Management.Automation.ConfirmImpact]::Medium)
            )
            $NeedServerPrompt = $WinGetAvailable -and (-not $SkipWinGet) -and (-not $SkipServerPrompt) -and (-not $ShouldProcessHandlesConsent)

            if ($WinGetAvailable -and (-not $SkipWinGet)) {
                $ShouldUpdateWinGet = $PSCmdlet.ShouldProcess('WinGet packages', 'Upgrade all user-scoped packages')
            }

            if ($NeedServerPrompt) {
                $WindowsOsCaption = Get-WindowsOperatingSystemCaption

                if ([string]::IsNullOrWhiteSpace($WindowsOsCaption)) {
                    Write-Warning -Message 'Unable to determine the Windows operating system caption. Skipping WinGet updates as a safety precaution.'
                    $SkipWinGet = $true
                    $ShouldUpdateWinGet = $false
                }
            }

            if ($ShouldUpdateWinGet -and $NeedServerPrompt -and ($WindowsOsCaption -match 'Server')) {
                # If on Windows Server, prompt to continue before automatically updating packages.
                Write-Warning -Message 'This is a server and updates could affect production systems. Do you want to continue with updating packages?'

                $Result = Read-WinGetServerChoice
                switch ($Result) {
                    0 {
                        Write-Verbose 'Continuing with WinGet package updates.'
                    }
                    1 {
                        $SkipWinGet = $true
                        $ShouldUpdateWinGet = $false
                    }
                }
            }

            if (-not $SkipWinGet) {
                if ($WinGetAvailable) {
                    if ($ShouldUpdateWinGet -or $WhatIfPreference) {
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
                    }
                    if ($ShouldUpdateWinGet) {
                        Invoke-WinGetUpgrade
                    }
                } else {
                    Write-Host '[4] WinGet was not found. Skipping WinGet update.'
                }
            } else {
                Write-Host '[4] Skipping WinGet'
            }
        } else {
            Write-Verbose '[4] Not Windows. Skipping WinGet.'
        }
        #endregion UpdateWinget

        #region UpdateLinuxPackages
        # Early testing. No progress bar yet. Need to check for admin, different distros, and different package managers.
        if ($Platform -eq 'Linux') {
            # Determine if we need sudo (not needed if already root)
            $NeedsSudo = -not (Test-IsElevated)

            if (Test-PSPreworkoutCommand -Name 'apt') {
                Write-Host '[5] Updating apt packages.'
                if ($PSCmdlet.ShouldProcess('apt packages', 'Update and upgrade packages')) {
                    if ($NeedsSudo) {
                        & sudo apt update
                        if ($AcceptPrompts) {
                            & sudo apt upgrade -y
                        } else {
                            & sudo apt upgrade
                        }
                    } else {
                        & apt update
                        if ($AcceptPrompts) {
                            & apt upgrade -y
                        } else {
                            & apt upgrade
                        }
                    }
                }
            }
            if (Test-PSPreworkoutCommand -Name 'dnf') {
                Write-Host '[5] Updating dnf packages.'
                if ($PSCmdlet.ShouldProcess('dnf packages', 'Update packages')) {
                    if ($NeedsSudo) {
                        if ($AcceptPrompts) {
                            & sudo dnf update -y
                        } else {
                            & sudo dnf update
                        }
                    } else {
                        if ($AcceptPrompts) {
                            & dnf update -y
                        } else {
                            & dnf update
                        }
                    }
                }
            }
        } else {
            Write-Verbose '[5] Not Linux. Skipping section.'
        }
        #endregion UpdateLinuxPackages

        #region UpdateMacOS
        # Early testing. No progress bar yet. Need to check for admin and different package managers.
        if ($Platform -eq 'macOS') {
            if ($PSCmdlet.ShouldProcess('macOS software updates', 'List available updates')) {
                softwareupdate -l
            }
            if (Test-PSPreworkoutCommand -Name 'brew') {
                Write-Host '[6] Updating brew packages.'
                if ($PSCmdlet.ShouldProcess('Homebrew packages', 'Update and upgrade packages')) {
                    brew update
                    brew upgrade
                }
            }
        } else {
            Write-Verbose '[6] Not macOS. Skipping section.'
        }
        #endregion UpdateMacOS

        $OptionalCliUpdates = @(
            @{
                CommandName      = 'gh'
                DisplayName      = '[7] Updating GitHub CLI Extensions'
                CurrentOperation = 'Updating GitHub CLI Extensions'
                TargetName       = 'GitHub CLI extensions'
                ActionName       = 'Upgrade all installed extensions'
                PercentComplete  = 90
                UpdateCommand    = {
                    Invoke-GitHubCliExtensionUpgrade
                }
            }
            @{
                CommandName      = 'copilot'
                DisplayName      = '[8] Updating GitHub Copilot CLI'
                CurrentOperation = 'Updating GitHub Copilot CLI'
                TargetName       = 'GitHub Copilot CLI'
                ActionName       = 'Update installed CLI'
                PercentComplete  = 95
                UpdateCommand    = {
                    Invoke-GitHubCopilotCliUpdate
                }
            }
        )

        foreach ($CliUpdate in $OptionalCliUpdates) {
            & $InvokeOptionalCliUpdate @CliUpdate
        }

        #region UpdateChocolatey
        # Upgrade Chocolatey packages. Need to check for admin to avoid errors/warnings.
        if ((Test-PSPreworkoutCommand -Name 'choco') -and $IncludeChocolatey) {
            # Update the outer progress bar
            $PercentCompleteOuter = 98
            $ProgressParamOuter = @{
                Id               = 0
                Activity         = 'Update Everything'
                CurrentOperation = 'Updating Chocolatey Packages'
                Status           = "Progress: $PercentCompleteOuter`% Complete"
                PercentComplete  = $PercentCompleteOuter
            }
            Write-Progress @ProgressParamOuter
            Write-Host '[9] Updating Chocolatey Packages'
            # Add a function/parameter to run these two feature configuration options, which requires admin to set.
            if (Test-IsElevated) {
                # Oops, this depends on PSPreworkout being installed or that function otherwise being available.
                if ($PSCmdlet.ShouldProcess('Chocolatey features', 'Enable global confirmation and disable non-elevated warnings')) {
                    choco feature enable -n=allowGlobalConfirmation
                    choco feature disable --name=showNonElevatedWarnings
                }
            } else {
                Write-Verbose "Run once as an administrator to disable Chocolatey's showNonElevatedWarnings." -Verbose
            }
            if ($PSCmdlet.ShouldProcess('Chocolatey packages', 'Upgrade Chocolatey and all packages')) {
                choco upgrade chocolatey -y --limit-output --accept-license --no-color
                choco upgrade all -y --limit-output --accept-license --no-color
            }
            # Padding to reset host before updating the progress bar.
            Write-Host ' '
        } else {
            Write-Host '[9] Skipping Chocolatey'
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
