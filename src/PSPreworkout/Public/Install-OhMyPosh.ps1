function Install-OhMyPosh {
    <#
    .SYNOPSIS
    Install Oh My Posh and add it to your profile.

    .DESCRIPTION
    An over-engineered script to install Oh My Posh. This script exists as an exercise and is not intended for production use.

    .PARAMETER Method
    Specify which tool to install Oh My Posh with.

    - chocolatey
    - direct (default)
    - scoop
    - winget

    .PARAMETER WingetSource
    Specify which source to install from.

        - winget  - Install from winget (default).
        - msstore - Install from the Microsoft Store.

    .PARAMETER InstallNerdFont
    Use this switch if you want to install a nerd font for full glyph capabilities in your prompt.

    .PARAMETER Font
    Choose a nerd font to install.

    - Default - Installs "Meslo" as the default nerd font.
    - Select  - Lets you choose a nerd font from the list.

    .EXAMPLE
    Install-OhMyPosh

    .NOTES
    Author: Sam Erde
    Version: 0.1.0
    Modified: 2024-10-23
#>
    [CmdletBinding(SupportsShouldProcess, HelpUri = 'https://day3bits.com/PSPreworkout/Install-OhMyPosh')]
    param (
        [Parameter()]
        [ValidateSet('winget', 'msstore')]
        [string]$WingetSource = 'winget',
        [Parameter()]
        [ValidateSet('chocolatey', 'direct', 'scoop', 'winget')]
        [string]$Method = 'direct',

        [Parameter(ParameterSetName = 'Font')]
        [switch]$InstallNerdFont,
        [Parameter (ParameterSetName = 'Font')]
        [ValidateSet('Default', 'Select One', 'Meslo')]
        [string]$Font = 'Default'
    )

    # Send non-identifying usage statistics to PostHog.
    Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

    switch ($Method) {
        chocolatey {
            if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
                if ($PSCmdlet.ShouldProcess('Oh My Posh', 'Install with Chocolatey')) {
                    choco install oh-my-posh
                }
            } else {
                Write-Error -Message 'Chocolatey was not found. Please install it or try another method.' -ErrorAction Stop
            }
        }
        winget {
            # Install Oh My Posh using Winget
            if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
                if ($PSCmdlet.ShouldProcess('Oh My Posh', "Install with WinGet from $WingetSource")) {
                    winget install --id JanDeDobbeleer.OhMyPosh --source $WingetSource
                }
            } else {
                throw 'WinGet was not found. Install WinGet first or choose another installation method.'
            }
        }
        scoop {
            # Install Oh My Posh using Scoop
            if ($PSCmdlet.ShouldProcess('Oh My Posh', 'Install with Scoop')) {
                scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
            }
        }
        direct {
            # Download and run the Oh My Posh install script directly from ohmyposh.dev
            if ($PSCmdlet.ShouldProcess('Oh My Posh install script', 'Download and execute')) {
                $InstallerPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'oh-my-posh-install.ps1'
                try {
                    Invoke-RestMethod -Uri 'https://ohmyposh.dev/install.ps1' -OutFile $InstallerPath -ErrorAction Stop
                    & $InstallerPath
                } finally {
                    Remove-Item -Path $InstallerPath -ErrorAction SilentlyContinue
                }
            }
        }
    }

    switch ($InstallNerdFont) {
        False {
            Write-Debug 'Not installing a nerd fonts'
        }
        True {
            if ($Font -eq 'Default' -or $Font -eq 'Meslo') {
                $FontName = 'Meslo'
            } else {
                $FontName = $null
            }

            Write-Information -MessageData "Installing as current user to avoid requiring local admin rights. Please see notes at https://ohmyposh.dev/docs/installation/fonts. `n" -InformationAction Continue
            if ($PSCmdlet.ShouldProcess("Oh My Posh font '$FontName'", 'Install for current user')) {
                oh-my-posh font install $FontName --user
            }
            # To Do: Script the configuration of Windows Terminal, VS Code, and default shell font in Windows registry.
            Write-Information -MessageData 'Please be sure to configure your shell to use the new font. See https://ohmyposh.dev/docs/installation/fonts.'
        }
    }

    $ProfileInstructions = @'
If Oh My Posh installed successfully, your next step will be to choose a theme and add Oh My Posh
to your PowerShell profile using one of the commands below.

    Default Theme:

        oh-my-posh init pwsh | Invoke-Expression

    Custom theme example:

        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/kali-minimal.omp.json" | Invoke-Expression

Once added, reload your profile by running:

    . $PROFILE

'@
    Write-Information -MessageData $ProfileInstructions -InformationAction Continue
}
