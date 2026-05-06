function Initialize-PSEnvironmentConfiguration {
    <#
    .SYNOPSIS
    Initialize configuration your PowerShell environment and git.

    .DESCRIPTION
    Install supporting packages, configure git, and set your console font with this function.

    .PARAMETER Name
    Your name to be used for git commits.

    .PARAMETER Email
    Your email to be used for git commits.

    .PARAMETER CentralProfile
    The file path to your central PowerShell profile.

    .PARAMETER Font
    The font to use for your consoles (PowerShell, Windows PowerShell, git bash, etc.)

    .PARAMETER Modules
    PowerShell modules to install.

    .PARAMETER SkipModules
    Option to skip installation of default modules.

    .PARAMETER PickModules
    Choose which modules you want to install.

    .PARAMETER Packages
    Packages to install with winget.

    .PARAMETER SkipPackages
    Option to skip installation of default packages.

    .PARAMETER PickPackages
    Choose which packages you want to install.

    .EXAMPLE
    Initialize the PowerShell working environment with a custom font, and set my name and email address for Git commits.

    Initialize-PSEnvironmentConfiguration -Name 'Sam Erde' -Email 'sam@example.local' -ConsoleFont 'FiraCode Nerd Font'

    .NOTES
    Author: Sam Erde
    Version: 0.0.3
    Modified: 2024/11/08

    To Do
        Add status/verbose output of changes being made
        Create basic starter profile if none exist
        Create dot-sourced profile
        Create interactive picker for packages and modules (separate functions)
        Bootstrap Out-GridView or Out-ConsoleGridView for the interactive picker
        Do not install already installed packages
        Do not install ConsoleGuiTools in Windows PowerShell
    #>

    [CmdletBinding(SupportsShouldProcess, HelpUri = 'https://day3bits.com/PSPreworkout/Initialize-PSEnvironmentConfiguration')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Argument completers are weird.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'PSReadLine Handler')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [Alias('Init-PSEnvConfig')]
    param (
        # Your name (used for Git config)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Your email address (used for Git config)
        [Parameter(Mandatory)]
        [ValidateScript({ [mailaddress]::new($_) })]
        [string]
        $Email,

        # Path to your central profile, if you use this feature (draft)
        # [Parameter()]
        # [ValidateScript({ Test-Path -Path $_ -PathType Leaf -IsValid })]
        # [string]
        # $CentralProfile,

        # The font that you want to use for consoles
        [Parameter()]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                [System.Drawing.Text.InstalledFontCollection]::new().Families |
                    Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
                        ForEach-Object { "'$($_.Name)'" }
            })]
        [string]$Font,

        # WinGet packages to install
        [Parameter()]
        [string[]]
        $Packages = @('Microsoft.WindowsTerminal', 'git.git', 'JanDeDobbeleer.OhMyPosh'),

        # Do not install any packages
        [Parameter()]
        [switch]
        $SkipPackages,

        # Choose from a list of packages to install (draft)
        # [Parameter()]
        # [switch]
        # $PickPackages,

        # PowerShell modules to install or force updates on
        [Parameter()]
        [string[]]
        $Modules = @('CompletionPredictor', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.PSResourceGet', 'posh-git', 'PowerShellForGitHub', 'Terminal-Icons', 'PSReadLine', 'PowerShellGet'),

        # Do not install any modules
        [Parameter()]
        [switch]
        $SkipModules

        # Choose from a list of PowerShell modules to install (draft)
        # [Parameter()]
        # [switch]
        # $PickModules
    )

    begin {
        # Send non-identifying usage statistics to PostHog.
        Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

        # Suppress PSScriptAnalyzer Errors
        $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null
    }

    process {
        #region Configure Git
        if ($PSBoundParameters.ContainsKey('Name') -and $PSCmdlet.ShouldProcess('Git global user.name', "Set to $Name")) {
            git config --global user.name $Name
        }
        if ($PSBoundParameters.ContainsKey('Email') -and $PSCmdlet.ShouldProcess('Git global user.email', "Set to $Email")) {
            git config --global user.email $Email
        }
        #endregion Configure Git


        #region Install PowerShell modules
        if ($PSCmdlet.ShouldProcess('PSGallery', 'Set PowerShellGet repository as trusted')) {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }
        if ($Modules -and -not $SkipModules.IsPresent) {
            foreach ($module in $Modules) {
                if ($PSCmdlet.ShouldProcess($module, 'Install and import PowerShell module')) {
                    Remove-Module -Name $module -Force -ErrorAction SilentlyContinue
                    $ModuleSplat = @{
                        Name       = $module
                        Scope      = 'CurrentUser'
                        Repository = 'PSGallery'
                    }
                    try {
                        Write-Verbose "Installing module: $module"
                        Install-Module @ModuleSplat -AllowClobber -Force
                    } catch {
                        $_
                    }
                    Import-Module -Name $module
                }
            }
        }
        # Update Pester and ignore the publisher warning
        if ($PSCmdlet.ShouldProcess('Pester', 'Install latest module with publisher-check bypass')) {
            Install-Module -Name Pester -Repository PSGallery -SkipPublisherCheck -AllowClobber -Force
        }
        #endregion Install PowerShell modules


        #region Default Settings, All Versions
        if ($PSCmdlet.ShouldProcess('PowerShell session defaults', 'Set default parameter values and UTF-8 encoding')) {
            $PSDefaultParameterValues = @{
                'ConvertTo-Csv:NoTypeInformation' = $True # Does not exist in pwsh
                'ConvertTo-Xml:NoTypeInformation' = $True
                'Export-Csv:NoTypeInformation'    = $True # Does not exist in pwsh
                'Format-[WT]*:AutoSize'           = $True
                '*:Encoding'                      = 'utf8'
                'Out-Default:OutVariable'         = 'LastOutput'
            }

            # Set input and output encoding both to UTF8 (already default in pwsh)
            $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
        }

        $PSReadLineOptions = @{
            HistoryNoDuplicates           = $true
            HistorySearchCursorMovesToEnd = $true
        }
        if ($PSCmdlet.ShouldProcess('PSReadLine', 'Set history behavior')) {
            Set-PSReadLineOption @PSReadLineOptions
        }

        # Do not write to history file if command was less than 4 characters. Borrowed from Sean Wheeler.
        if ($PSCmdlet.ShouldProcess('PSReadLine', 'Set filtered history handler')) {
            $global:__DefaultHistoryHandler = (Get-PSReadLineOption).AddToHistoryHandler
            Set-PSReadLineOption -AddToHistoryHandler {
                param([string]$Line)
                $DefaultResult = $global:__defaultHistoryHandler.Invoke($Line)
                if ($DefaultResult -eq 'MemoryAndFile') {
                    if ($Line.Length -gt 3 -and $Line[0] -ne ' ' -and $Line[-1] -ne ';') {
                        return 'MemoryAndFile'
                    } else {
                        return 'MemoryOnly'
                    }
                } else {
                    return $DefaultResult
                }
            }
        }
        #endregion Default Settings, All Versions


        #region Version-Specific Settings
        if ($PSVersionTable.PSVersion -lt '6.0') {
            if ($PSCmdlet.ShouldProcess('PSReadLine', 'Set inline prediction view style')) {
                Set-PSReadLineOption -PredictionViewStyle Inline -PredictionSource History
            }
        } else {
            if ($PSCmdlet.ShouldProcess('PSReadLine', 'Set list prediction view style')) {
                Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin
            }

            if ($IsLinux -or $IsMacOS) {
                if ($PSCmdlet.ShouldProcess('Microsoft.PowerShell.UnixTabCompletion', 'Install and configure Unix tab completion')) {
                    Install-Module Microsoft.PowerShell.UnixTabCompletion
                    Install-PSUnixTabCompletion
                }
            }
        }
        #endregion Version-Specific Settings


        #region Font
        # Set the font for all registered consoles (Windows only)
        if ($PSBoundParameters.ContainsKey('Font')) {
            if ($IsLinux -or $IsMacOS) {
                Write-Information 'Setting the font is not yet supported in Linux or macOS.' -InformationAction Continue
            } else {
                try {
                    Get-ChildItem -Path 'HKCU:\Console' | ForEach-Object {
                        $ConsolePath = (($_.Name).Replace('HKEY_CURRENT_USER', 'HKCU:'))
                        if ($PSCmdlet.ShouldProcess($ConsolePath, "Set console font to $Font")) {
                            Set-ItemProperty -Path $ConsolePath -Name 'FaceName' -Value $Font
                        }
                    }
                } catch {
                    Write-Warning "Failed to set console font: $_"
                }
            }
        }
        #endregion Font


        #region Install Packages
        # Install packages
        if ($Packages -and -not $SkipPackages.IsPresent) {
            foreach ($package in $Packages) {
                try {
                    Write-Verbose "Installing package: $package."
                    if ($PSCmdlet.ShouldProcess($package, 'Install WinGet package')) {
                        winget install --id $package --accept-source-agreements --accept-package-agreements --source winget --scope user --silent
                    }
                } catch {
                    $_
                }
            }
        }
        #endregion Install Packages

        #region Windows Terminal
        if ($IsWindows -or ($PSVersionTable.PSEdition -eq 'Desktop')) {
            $KeyPath = 'HKCU:\Console\%%Startup'
            if (-not (Test-Path -Path $KeyPath)) {
                try {
                    if ($PSCmdlet.ShouldProcess($KeyPath, 'Create registry key')) {
                        New-Item -Path $KeyPath >$null
                    }
                } catch {
                    throw "Failed to create registry key: $_"
                }
            } else {
                Write-Verbose -Message "Key already exists: $KeyPath"
            }

            # Set Windows Terminal as the default terminal application if it is installed on this system.
            if (Test-Path -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe" -PathType Leaf) {
                # Set Windows Terminal as the default terminal application for Windows.
                try {
                    if ($PSCmdlet.ShouldProcess($KeyPath, 'Set Windows Terminal as default terminal')) {
                        New-ItemProperty -Path $KeyPath -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Force >$null
                        New-ItemProperty -Path $KeyPath -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Force >$null
                    }
                } catch {
                    throw "Failed to set default terminal: $_"
                }
            }
        } else {
            Write-Verbose 'Windows Terminal registry configuration is only supported on Windows.'
        }
        #endregion Windows Terminal

    } # end process block

    end {
    } # end end block
}

# Register the argument completer for Set-ConsoleFont.
Register-ArgumentCompleter -CommandName Set-ConsoleFont -ParameterName Font -ScriptBlock {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Argument completers are weird.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    [System.Drawing.Text.InstalledFontCollection]::new().Families |
        Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
            ForEach-Object { "'$($_.Name)'" }

    # Suppress PSScriptAnalyzer Errors
    $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null
}
