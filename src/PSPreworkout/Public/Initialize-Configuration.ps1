function Initialize-Configuration {
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

    .PARAMETER ConsoleFont
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
    Initialize-Configuration

    Init-Configuration -Name 'Sam Erde' -Email 'sam@example.local' -ConsoleFont 'FiraCode Nerd Font'

    .NOTES
        To Do
          Create basic starter profile if none exist
          Create dot-sourced profile
          Create interactive picker for packages and modules (separate functions)
          Bootstrap Out-GridView or Out-ConsoleGridView
    #>

    [CmdletBinding()]
    [Alias('Init-Config', 'Init-Configuration')]
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

        <#
        # Path to your central profile repository directory, if you use this feature
        [Parameter(
            ParameterSetName = 'CentralProfileRepository'
        )]
            [Alias('Repo')]
            [ValidateScript({Test-Path -Path $_ -PathType Container -IsValid})]
            [string]
            $ProfileRepository,
        #>

        # Path to your central profile, if you use this feature
        [Parameter()]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -IsValid })]
        [string]
        $CentralProfile,

        # The font that you want to use for consoles
        # Would be cool to register an autocompleter for this
        [Parameter()]
        [Alias('Font')]
        [ArgumentCompleter({ FontNameCompleter @args })]
        [string]
        $ConsoleFont,

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

    }

    process {
        # Configure git user settings
        if ($PSBoundParameters.ContainsKey('Name')) { git config --global user.name $Name }
        if ($PSBoundParameters.ContainsKey('Email')) { git config --global user.email $Email }

        # Set the font for all registered consoles (Windows only)
        if ($PSBoundParameters.ContainsKey('ConsoleFont')) {
            if ($IsLinux -or $IsMacOS) {
                Write-Information 'Setting the font is not yet supported in Linux or macOS.' -InformationAction Continue
                continue
            }
            Get-ChildItem -Path 'HKCU:\Console' | ForEach-Object {
                Set-ItemProperty -Path (($_.Name).Replace('HKEY_CURRENT_USER', 'HKCU:')) -Name 'FaceName' -Value $ConsoleFont
            }
        }

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
    } # end process block

    end {

    }
}

function FontNameCompleter {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter')]
    param(
        $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    )

    Add-Type -AssemblyName System.Drawing
    $MonospaceFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families | Where-Object {
        $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP'
    } | Select-Object -ExpandProperty Name

    if ($fakeBoundParameters.ContainsKey('ConsoleFont')) {
        $MonospaceFonts | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
            "'$_'"
        }
    } else {
        $MonospaceFonts | ForEach-Object {
            "'$_'"
        }
    }

}

Register-ArgumentCompleter -CommandName Initialize-Configuration -ParameterName ConsoleFont -ScriptBlock $FontNameCompleter
