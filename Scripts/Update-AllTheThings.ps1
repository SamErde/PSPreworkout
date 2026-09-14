<#PSScriptInfo
.DESCRIPTION A script to automatically update all PowerShell modules, PowerShell Help, GitHub CLI extensions, GitHub Copilot CLI, and packages (apt, brew, Chocolatey, WinGet).
.VERSION 0.6.0
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

function Write-UpdateAllTheThingsProgress {
    <#
    .SYNOPSIS
    Writes progress for Update-AllTheThings.

    .DESCRIPTION
    Centralizes the parent progress record used by Update-AllTheThings and its
    private update helpers.

    .PARAMETER CurrentOperation
    The operation currently being performed.

    .PARAMETER PercentComplete
    The percentage of the overall update that is complete.

    .PARAMETER Completed
    Completes and removes the progress record.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentOperation,

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$PercentComplete = 0,

        [Parameter()]
        [switch]$Completed
    )

    if ($Completed) {
        Write-Progress -Id 0 -Activity 'Update Everything' -Completed
        return
    }

    $ProgressParameters = @{
        Id               = 0
        Activity         = 'Update Everything'
        CurrentOperation = $CurrentOperation
        Status           = "Progress: $PercentComplete`% Complete"
        PercentComplete  = $PercentComplete
    }
    Write-Progress @ProgressParameters
}

function Invoke-UpdateNativeCommand {
    <#
    .SYNOPSIS
    Invokes a native update command and validates its exit code.

    .DESCRIPTION
    Provides consistent invocation and explicit failure handling for native
    package-manager commands.

    .PARAMETER Name
    The native command to invoke.

    .PARAMETER ArgumentList
    Arguments passed to the native command.

    .PARAMETER FailureMessage
    Context included in the terminating error when the command fails.

    .PARAMETER Command
    An invocation seam used by unit tests.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [AllowEmptyCollection()]
        [string[]]$ArgumentList = @(),

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FailureMessage,

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            param($CommandName, $CommandArguments)

            & $CommandName @CommandArguments | Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command $Name $ArgumentList
    if ($ExitCode -ne 0) {
        throw "$FailureMessage failed with exit code $ExitCode."
    }
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

function Set-UpdateRepositoryTrust {
    <#
    .SYNOPSIS
    Trusts supported PowerShell Gallery repositories.

    .DESCRIPTION
    Configures PSGallery as trusted for the installed PowerShellGet and
    PSResourceGet clients.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param()

    Write-Verbose 'Set the PowerShell Gallery as a trusted installation source.'

    if (
        (Test-PSPreworkoutCommand -Name 'Set-PSRepository') -and
        $PSCmdlet.ShouldProcess('PSGallery', 'Set PowerShellGet repository as trusted')
    ) {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    }

    if (
        (Test-PSPreworkoutCommand -Name 'Set-PSResourceRepository') -and
        $PSCmdlet.ShouldProcess('PSGallery', 'Set PSResourceGet repository as trusted')
    ) {
        Set-PSResourceRepository -Name 'PSGallery' -Trusted
    }
}

function Update-PowerShellArtifact {
    <#
    .SYNOPSIS
    Updates installed PowerShell modules, scripts, and help.

    .DESCRIPTION
    Handles PowerShell-native update operations and their progress reporting.

    .PARAMETER SkipModules
    Skips installed module updates.

    .PARAMETER SkipScripts
    Skips installed script updates.

    .PARAMETER SkipHelp
    Skips PowerShell help updates.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$SkipModules,

        [Parameter()]
        [switch]$SkipScripts,

        [Parameter()]
        [switch]$SkipHelp
    )

    Write-UpdateAllTheThingsProgress -CurrentOperation 'Getting Installed PowerShell Modules' -PercentComplete 1

    if ($SkipModules) {
        Write-Information '[1] Skipping PowerShell Modules' -InformationAction Continue
    } elseif (-not (Test-PSPreworkoutCommand -Name 'Get-InstalledModule')) {
        Write-Warning 'Get-InstalledModule was not found. Skipping PowerShell module updates.'
    } else {
        Write-Information '[1] Getting Installed PowerShell Modules' -InformationAction Continue
        $Modules = @(Get-InstalledModule)
        Write-Information "[2] Updating $($Modules.Count) PowerShell Modules" -InformationAction Continue

        $ModuleIndex = 0
        foreach ($Module in $Modules) {
            ++$ModuleIndex
            $ModulePercent = [math]::Ceiling(($ModuleIndex / $Modules.Count) * 100)
            $OverallPercent = [math]::Ceiling(10 + (60 * ($ModulePercent / 100)))

            Write-UpdateAllTheThingsProgress -CurrentOperation "Updating PowerShell module $($Module.Name)" -PercentComplete $OverallPercent
            Write-Progress -Id 1 -ParentId 0 -Activity 'Updating PowerShell Modules' `
                -CurrentOperation $Module.Name -Status "Progress: $ModulePercent`% Complete" `
                -PercentComplete $ModulePercent

            if ($Module.Version -match 'alpha|beta|prerelease|preview') {
                Write-Information "`t`tSkipping $($Module.Name) because a prerelease version is currently installed." -InformationAction Continue
                continue
            }

            try {
                if ($PSCmdlet.ShouldProcess($Module.Name, 'Update PowerShell module')) {
                    Update-Module -Name $Module.Name
                }
            } catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                Write-Warning "Unable to update PowerShell module '$($Module.Name)': $($_.Exception.Message)"
            }
        }
    }

    Write-Progress -Id 1 -Activity 'Updating PowerShell Modules' -Completed

    if ($SkipScripts) {
        Write-Information '[2] Skipping PowerShell Scripts' -InformationAction Continue
    } elseif (-not (Test-PSPreworkoutCommand -Name 'Update-Script')) {
        Write-Warning 'Update-Script was not found. Skipping PowerShell script updates.'
    } else {
        Write-Information '[2] Updating PowerShell Scripts' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('Installed PowerShell scripts', 'Update scripts')) {
            Update-Script
        }
    }

    Write-UpdateAllTheThingsProgress -CurrentOperation 'Updating PowerShell Help' -PercentComplete 70

    if ($SkipHelp) {
        Write-Information '[3] Skipping PowerShell Help' -InformationAction Continue
    } else {
        Write-Information '[3] Updating PowerShell Help' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('PowerShell help files', 'Update help')) {
            if ((Get-Culture).LCID -eq 127) {
                Update-Help -UICulture en-US -ErrorAction SilentlyContinue
            } else {
                Update-Help -ErrorAction SilentlyContinue
            }
        }
    }
}

function Update-WinGetPackage {
    <#
    .SYNOPSIS
    Updates user-scoped WinGet packages.

    .DESCRIPTION
    Applies Windows Server safeguards before invoking WinGet.

    .PARAMETER Skip
    Skips WinGet package updates.

    .PARAMETER AcceptPrompts
    Bypasses the additional Windows Server confirmation prompt.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$Skip,

        [Parameter()]
        [switch]$AcceptPrompts
    )

    if ($Skip) {
        Write-Information '[4] Skipping WinGet' -InformationAction Continue
        return
    }

    if (-not (Test-PSPreworkoutCommand -Name 'winget')) {
        Write-Information '[4] WinGet was not found. Skipping WinGet update.' -InformationAction Continue
        return
    }

    $ShouldUpdate = $PSCmdlet.ShouldProcess('WinGet packages', 'Upgrade all user-scoped packages')
    $SkipServerPrompt = $AcceptPrompts -or $WhatIfPreference -or (
        $PSBoundParameters.ContainsKey('Confirm') -and (-not $Confirm)
    )
    $ShouldProcessHandlesConsent = ($PSBoundParameters.ContainsKey('Confirm') -and $Confirm) -or (
        ($ConfirmPreference -ne [System.Management.Automation.ConfirmImpact]::None) -and
        (([System.Management.Automation.ConfirmImpact]$ConfirmPreference) -le [System.Management.Automation.ConfirmImpact]::Medium)
    )
    $NeedServerPrompt = (-not $SkipServerPrompt) -and (-not $ShouldProcessHandlesConsent)

    if ($NeedServerPrompt) {
        $WindowsOsCaption = Get-WindowsOperatingSystemCaption
        if ([string]::IsNullOrWhiteSpace($WindowsOsCaption)) {
            Write-Warning -Message 'Unable to determine the Windows operating system caption. Skipping WinGet updates as a safety precaution.'
            return
        }

        if ($ShouldUpdate -and ($WindowsOsCaption -match 'Server')) {
            Write-Warning -Message 'This is a server and updates could affect production systems. Do you want to continue with updating packages?'
            if ((Read-WinGetServerChoice) -ne 0) {
                return
            }
            Write-Verbose 'Continuing with WinGet package updates.'
        }
    }

    if ($ShouldUpdate -or $WhatIfPreference) {
        Write-Information '[4] Updating WinGet Packages' -InformationAction Continue
        Write-UpdateAllTheThingsProgress -CurrentOperation 'Updating WinGet Packages' -PercentComplete 80
    }

    if ($ShouldUpdate) {
        Invoke-WinGetUpgrade
    }
}

function Update-LinuxPackage {
    <#
    .SYNOPSIS
    Updates packages with supported Linux package managers.

    .DESCRIPTION
    Updates apt and dnf packages, using sudo only when the current process is
    not elevated.

    .PARAMETER AcceptPrompts
    Passes the non-interactive acceptance argument to package managers.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$AcceptPrompts
    )

    $AptAvailable = Test-PSPreworkoutCommand -Name 'apt'
    $DnfAvailable = Test-PSPreworkoutCommand -Name 'dnf'
    if ((-not $AptAvailable) -and (-not $DnfAvailable)) {
        return
    }

    $NeedsSudo = -not (Test-IsElevated)

    if ($AptAvailable) {
        Write-Information '[5] Updating apt packages.' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('apt packages', 'Update and upgrade packages')) {
            $CommandName = if ($NeedsSudo) { 'sudo' } else { 'apt' }
            $UpdateArguments = if ($NeedsSudo) { @('apt', 'update') } else { @('update') }
            [string[]]$UpgradeArguments = if ($NeedsSudo) { @('apt', 'upgrade') } else { @('upgrade') }
            if ($AcceptPrompts) {
                $UpgradeArguments += '-y'
            }

            Invoke-UpdateNativeCommand -Name $CommandName -ArgumentList $UpdateArguments -FailureMessage 'apt package index update'
            Invoke-UpdateNativeCommand -Name $CommandName -ArgumentList $UpgradeArguments -FailureMessage 'apt package upgrade'
        }
    }

    if ($DnfAvailable) {
        Write-Information '[5] Updating dnf packages.' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('dnf packages', 'Update packages')) {
            $CommandName = if ($NeedsSudo) { 'sudo' } else { 'dnf' }
            [string[]]$Arguments = if ($NeedsSudo) { @('dnf', 'update') } else { @('update') }
            if ($AcceptPrompts) {
                $Arguments += '-y'
            }

            Invoke-UpdateNativeCommand -Name $CommandName -ArgumentList $Arguments -FailureMessage 'dnf package update'
        }
    }
}

function Update-MacOSPackage {
    <#
    .SYNOPSIS
    Updates supported macOS software.

    .DESCRIPTION
    Lists macOS software updates and updates Homebrew packages when Homebrew is
    installed.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param()

    if ($PSCmdlet.ShouldProcess('macOS software updates', 'List available updates')) {
        Invoke-UpdateNativeCommand -Name 'softwareupdate' -ArgumentList '-l' -FailureMessage 'macOS software update query'
    }

    if (Test-PSPreworkoutCommand -Name 'brew') {
        Write-Information '[6] Updating brew packages.' -InformationAction Continue
        if ($PSCmdlet.ShouldProcess('Homebrew packages', 'Update and upgrade packages')) {
            Invoke-UpdateNativeCommand -Name 'brew' -ArgumentList 'update' -FailureMessage 'Homebrew update'
            Invoke-UpdateNativeCommand -Name 'brew' -ArgumentList 'upgrade' -FailureMessage 'Homebrew upgrade'
        }
    }
}

function Update-OptionalCli {
    <#
    .SYNOPSIS
    Updates an optional command-line tool.

    .DESCRIPTION
    Runs a supplied update command when its command-line tool is installed.

    .PARAMETER CommandName
    The command used to detect whether the tool is installed.

    .PARAMETER DisplayName
    The status text displayed to the user.

    .PARAMETER CurrentOperation
    The operation shown in the progress record.

    .PARAMETER TargetName
    The ShouldProcess target.

    .PARAMETER ActionName
    The ShouldProcess action.

    .PARAMETER PercentComplete
    The overall completion percentage.

    .PARAMETER UpdateCommand
    The update operation to invoke.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CommandName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentOperation,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ActionName,

        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [scriptblock]$UpdateCommand
    )

    if (-not (Test-PSPreworkoutCommand -Name $CommandName)) {
        Write-Verbose "$DisplayName was skipped because $CommandName was not found."
        return
    }

    Write-Information $DisplayName -InformationAction Continue
    Write-UpdateAllTheThingsProgress -CurrentOperation $CurrentOperation -PercentComplete $PercentComplete
    if ($PSCmdlet.ShouldProcess($TargetName, $ActionName)) {
        & $UpdateCommand
    }
}

function Update-ChocolateyPackage {
    <#
    .SYNOPSIS
    Updates Chocolatey and installed Chocolatey packages.

    .DESCRIPTION
    Optionally configures Chocolatey features when elevated, then updates
    Chocolatey and all installed packages.

    .PARAMETER Include
    Enables Chocolatey package updates.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter()]
        [switch]$Include
    )

    if ((-not $Include) -or (-not (Test-PSPreworkoutCommand -Name 'choco'))) {
        Write-Information '[9] Skipping Chocolatey' -InformationAction Continue
        return
    }

    Write-UpdateAllTheThingsProgress -CurrentOperation 'Updating Chocolatey Packages' -PercentComplete 98
    Write-Information '[9] Updating Chocolatey Packages' -InformationAction Continue

    if (Test-IsElevated) {
        if ($PSCmdlet.ShouldProcess('Chocolatey features', 'Enable global confirmation and disable non-elevated warnings')) {
            Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList @(
                'feature', 'enable', '-n=allowGlobalConfirmation'
            ) -FailureMessage 'Chocolatey global confirmation configuration'
            Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList @(
                'feature', 'disable', '--name=showNonElevatedWarnings'
            ) -FailureMessage 'Chocolatey non-elevated warning configuration'
        }
    } else {
        Write-Verbose "Run once as an administrator to disable Chocolatey's showNonElevatedWarnings." -Verbose
    }

    if ($PSCmdlet.ShouldProcess('Chocolatey packages', 'Upgrade Chocolatey and all packages')) {
        $UpgradeArguments = @('-y', '--limit-output', '--accept-license', '--no-color')
        $SelfUpdateArguments = @('upgrade', 'chocolatey') + $UpgradeArguments
        $PackageUpdateArguments = @('upgrade', 'all') + $UpgradeArguments
        Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList $SelfUpdateArguments -FailureMessage 'Chocolatey self-update'
        Invoke-UpdateNativeCommand -Name 'choco' -ArgumentList $PackageUpdateArguments -FailureMessage 'Chocolatey package update'
    }

    Write-Information ' ' -InformationAction Continue
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'WhatIf and Confirm are forwarded to private helpers that call ShouldProcess.')]
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
