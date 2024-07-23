function Install-OhMyPosh {
<#
    .SYNOPSIS
        Install Oh My Posh and add it to your profile.

    .DESCRIPTION

    .PARAMETER Method
        Specify which tool to install Oh My Posh with.

            chocolatey
            direct (default)
            scoop
            winget

    .PARAMETER WingetSource
        Specify which source to install from.

            winget  - Install from winget (default).
            msstore - Install from the Microsoft Store.

    .PARAMETER InstallNerdFont
        Use this switch if you want to install a nerd font for full glyph capabilities in your prompt.

    .PARAMETER Font
        Choose a nerd font to install.

            Default - Installs "Meslo" as the default nerd font.
            Select  - Lets you choose a nerd font from the list.

    .NOTES
        Author: Sam Erde
        Created: 12/01/2023
#>
    [CmdletBinding()]
    param (
        [Parameter()]
            [ValidateSet("winget","msstore")]
            [string]$WingetSource = "winget",
        [Parameter()]
            [ValidateSet("chocolatey","direct","scoop","winget")]
            [string]$Method = "direct",

        [Parameter(ParameterSetName = 'Font')]
            [switch]$InstallNerdFont,
        [Parameter (ParameterSetName = 'Font')]
            [ValidateSet("Default","Select One","Meslo")]
            [string]$Font = "Default"
    )

    switch ($Method) {
        chocolatey {
            if (choco.exe) {
                choco install oh-my-posh
            }
            else {
                Write-Error -Message "Chocolatey was not found. Please install it or try another method." -ErrorAction Stop
            }
        }
        winget {
            # Install Oh My Posh using Winget
            if (winget.exe) {
                winget install --id JanDeDobbeleer.OhMyPosh --source $WingetSource
            }
            else {
                $Response = Read-Host -Prompt "Winget was not found. Would you like to try to install it?"
                if ($Response -eq "y" -or $Response -eq "yes") {
                    try {
                        $progressPreference = 'silentlyContinue'
                        Write-Information "Downloading WinGet and its dependencies..."
                        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
                        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
                        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
                        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
                        Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
                        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

                        if (winget.exe) {
                            winget install --id JanDeDobbeleer.OhMyPosh --source $WingetSource
                        }
                    }
                    catch {
                        Write-Error -Message "Sorry, we failed to download and install winget. Please refer to https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget."
                    }
                }
            }
        }
        scoop {
            # Install Oh My Posh using Scoop
            scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
        }
        direct {
            # Download and run the Oh My Posh install script directly from ohmyposh.dev
            Set-ExecutionPolicy Bypass -Scope Process -Force
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
        }
    }

    switch ($InstallNerdFont) {
        False {
            Write-Debug "Not installing a nerd fonts"
        }
        True {
            if ($Font -eq "Default" -or $Fond -eq "Meslo") {
                $FontName = "Meslo"
            }
            else {
                $FontName = $null
            }

            Write-Information -MessageData "Installing as current user to avoid requiring local admin rights. Please see notes at https://ohmyposh.dev/docs/installation/fonts. `n" -InformationAction Continue
            oh-my-posh font install $FontName --user
            # To Do: Script the configuration of Windows Terminal, VS Code, and default shell font in Windows registry.
            Write-Information -MessageData "Please be sure to configure your shell to use the new font. See https://ohmyposh.dev/docs/installation/fonts."
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

    oh-my-posh init pwsh | Invoke-Expression
}
