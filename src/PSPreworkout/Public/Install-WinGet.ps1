function Install-WinGet {
    <#
    .SYNOPSIS
    Install Winget (beta)

    .DESCRIPTION
    Install WinGet on Windows Sandbox (or on builds of Windows 10 prior to build 1709 that did not ship with it
    preinstalled). This script exists mostly as an exercise, as there are already many ways to install WinGet.

    .PARAMETER DownloadPath
    Path of the directory to save the downloaded packages in (optional).

    .PARAMETER DownloadOnly
    Download the packages without installing them (optional).

    .PARAMETER KeepDownload
    Keep the downloaded packages (optional).

    .EXAMPLE
    Install-WinGet

    .EXAMPLE
    Install-WinGet -KeepDownload

    Installs WinGet and keeps the downloaded AppX packages.

    .NOTES
    Author: Sam Erde
    Version: 0.1.0
    Modified: 2024-10-23

    To Do:
    - Check for newer versions of packages on GitHub
    - Error handling
    - Create the target folder if it does not already exist
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Install-WinGet')]
    param (

        # Path to download the packages to (directory must already exist)
        [Parameter()]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]
        $DownloadPath,

        # Option to only download and not install
        [Parameter()]
        [switch]
        $DownloadOnly,

        # Option to keep the downloaded packages
        [Parameter()]
        [switch]
        $KeepDownload
    )

    begin {
        # Send non-identifying usage statistics to PostHog.
        Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

        $StartTime = Get-Date

        if ($PSBoundParameters.ContainsKey('DownloadPath')) {
            $Path = $DownloadPath
        } else {
            $Path = $PWD
        }

        $DesktopAppInstallerPackage = Join-Path -Path $Path -ChildPath 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
        $VCLibsPackage = Join-Path -Path $Path -ChildPath 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
        $XamlPackage = Join-Path -Path $Path -ChildPath 'Microsoft.UI.Xaml.2.8.x64.appx'
    }

    process {
        $progressPreference = 'silentlyContinue'
        Write-Information 'Downloading WinGet and its dependencies...'
        Write-Verbose 'Downloading packages...'
        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $DesktopAppInstallerPackage
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile $VCLibsPackage
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile $XamlPackage

        if ($DownloadOnly.IsPresent) {
            Write-Output "WinGet package dependencies were downloaded in $([math]::Ceiling(((Get-Date) - $StartTime).TotalSeconds)) seconds."
        } else {
            Write-Verbose 'Installing packages...'
            Add-AppxPackage $XamlPackage
            Add-AppxPackage $VCLibsPackage
            Add-AppxPackage $DesktopAppInstallerPackage
            Write-Output "WinGet $(winget -v) is installed."
        }

        if ($KeepDownload.IsPresent -or $DownloadOnly.IsPresent) {
            Write-Output "The DesktopAppInstaller, VCLibs, and XML packages have been downloaded to $DownloadPath."
        } else {
            Remove-Item -Path $DesktopAppInstallerPackage
            Remove-Item -Path $VCLibsPackage
            Remove-Item -Path $XamlPackage
        }
    }

    end {
        Write-Verbose "WinGet $(winget -v) installed in $([math]::Ceiling(((Get-Date) - $StartTime).TotalSeconds)) seconds."
        Remove-Variable StartTime, DesktopAppInstallerPackage, VCLibsPackage, XamlPackage -ErrorAction SilentlyContinue
    }
}
