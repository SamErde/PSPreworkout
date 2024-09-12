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
        To Do
          Create basic starter profile if none exist
          Create dot-sourced profile
          Create interactive picker for packages and modules (separate functions)
          Bootstrap Out-GridView or Out-ConsoleGridView
    #>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Agument completers are weird.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'PSReadLine Handler')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [Alias('Init-PSEnvConfig')]
    param (
        # Your name (used for Git config)
        [Parameter()]
        [string]
        $Name,

        # Your email address (used for Git config)
        [Parameter()]
        [ValidateScript({ [mailaddress]::new($_) })]
        [string]
        $Email,

        # Path to your central profile, if you use this feature
        [Parameter()]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -IsValid })]
        [string]
        $CentralProfile,

        # The font that you want to use for consoles
        [Parameter()]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                [System.Drawing.Text.InstalledFontCollection]::new().Families |
                    Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
                        ForEach-Object { "'$($_.Name)'" }
            })]
        [string]$Font,

        # Packages to install
        [Parameter()]
        [string[]]
        $Packages = @('Microsoft.PowerShell', 'Microsoft.WindowsTerminal', 'git.git', 'JanDeDobbeleer.OhMyPosh'),

        # Do not install any packages
        [Parameter()]
        [switch]
        $SkipPackages,

        # Choose from a list of packages to install
        [Parameter()]
        [switch]
        $PickPackages,

        # PowerShell modules to install
        [Parameter()]
        [string[]]
        $Modules = @('CompletionPredictor', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.PSResourceGet', 'posh-git', 'PowerShellForGitHub', 'Terminal-Icons'),

        # Do not install any modules
        [Parameter()]
        [switch]
        $SkipModules,

        # Choose from a list of PowerShell modules to install
        [Parameter()]
        [switch]
        $PickModules
    )

    begin {
        # Suppress PSScriptAnalyzer Errors
        $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null
    }

    process {
        #region Configure Git
        if ($PSBoundParameters.ContainsKey('Name')) { git config --global user.name $Name }
        if ($PSBoundParameters.ContainsKey('Email')) { git config --global user.email $Email }
        #endregion Configure Git


        #region Default Settings, All Versions
        $PSDefaultParameterValues = @{
            'ConvertTo-Csv:NoTypeInformation' = $True
            'ConvertTo-Xml:NoTypeInformation' = $True
            'Export-Csv:NoTypeInformation'    = $True
            'Format-[WT]*:Autosize'           = $True
            'Get-Help:ShowWindow'             = $False
            '*:Encoding'                      = 'utf8'
            'Out-Default:OutVariable'         = 'LastOutput'
        }

        $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

        $PSReadLineOptions = @{
            HistoryNoDuplicates           = $true
            HistorySearchCursorMovesToEnd = $true
        }
        Set-PSReadLineOption @PSReadLineOptions

        # Do not write to history file if command was less than 4 characters. Borrowed from Sean Wheeler.
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
            }
            return $DefaultResult
        }
        #endregion Default Settings, All Versions


        #region Version-Specific Settings
        if ($PSVersionTable.PSVersion -lt '6.0') {
            Set-PSReadLineOption -PredictionViewStyle Inline -PredictionSource History
        } else {
            Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin

            if ($IsLinux -or $IsMacOS) {
                Install-Module Microsoft.PowerShell.UnixTabCompletion
                Install-PSUnixTabCompletion
            }
        }
        #endregion Version-Specific Settings


        #region Font
        # Set the font for all registered consoles (Windows only)
        if ($PSBoundParameters.ContainsKey('ConsoleFont') -or $PSBoundParameters.ContainsKey('Font')) {
            if ($IsLinux -or $IsMacOS) {
                Write-Information 'Setting the font is not yet supported in Linux or macOS.' -InformationAction Continue
                continue
            }
            Get-ChildItem -Path 'HKCU:\Console' | ForEach-Object {
                Set-ItemProperty -Path (($_.Name).Replace('HKEY_CURRENT_USER', 'HKCU:')) -Name 'FaceName' -Value $ConsoleFont
            }
        }
        #endregion Font


        #region Install Things
        # Install PowerShell modules
        if ($Modules -and -not $SkipModules.IsPresent) {
            foreach ($module in $Modules) {
                try {
                    Write-Verbose "Installing module: $module"
                    Install-Module -Name $module -Scope CurrentUser -AcceptLicense -Force
                } catch {
                    $_
                }
            }
        }

        # Install packages
        if ($Packages -and -not $SkipPackages.IsPresent) {
            foreach ($package in $Packages) {
                try {
                    Write-Verbose "Installing package: $package."
                    winget install --id $package --accept-source-agreements --accept-package-agreements --scope user
                } catch {
                    $_
                }
            }
        }
        #endregion Install Things
    } # end process block

    end {
    }
}

# Register the argument completer for Set-ConsoleFont.
Register-ArgumentCompleter -CommandName Set-ConsoleFont -ParameterName Font -ScriptBlock {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Agument completers are weird.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    [System.Drawing.Text.InstalledFontCollection]::new().Families |
        Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
            ForEach-Object { "'$($_.Name)'" }

    # Suppress PSScriptAnalyzer Errors
    $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null
}
