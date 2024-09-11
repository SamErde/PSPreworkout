function Get-PowerShellPortable {
    <#
        .SYNOPSIS
        Download a portable version of PowerShell 7x to run anywhere on demand.

        .DESCRIPTION
        This function helps you download a zipped version of PowerShell 7.x that can be run anywhere without needing to install.

        .PARAMETER Path
        Path of the directory to download the PowerShell zip file into.

        .PARAMETER Extract
        Extract the downloaded zip file.

        .EXAMPLE
        Get-PowerShellPortable

        .NOTES
        Author: Sam Erde
        Version: 0.0.1
        Modified: 2024-09-11
    #>

    [CmdletBinding()]
    [Alias('Get-PSPortable')]
    param (

    )

    $ReleaseUrl = 'https://github.com/PowerShell/PowerShell/releases/latest'
    $LatestReleaseUri = (Invoke-WebRequest -Uri $ReleaseUrl).BaseResponse.ResponseUri.OriginalString
    $ReleaseLinks = Invoke-WebRequest -Uri $LatestReleaseUri

    # Determine the platform and architecture
    $OS = $PSVersionTable.OS
    if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop' ) {
        $OS = 'Windows'
        $Architecture = if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') { 'x64' } else { 'x86' }
    }

    # Set the pattern for the ZIP file based on the OS and architecture
    $Pattern = if ($os -match 'Windows') {
        "win-$Architecture.zip"
    } elseif ($OS -match 'Linux') {
        "linux-$Architecture.tar.gz"
    } elseif ($OS -match 'Darwin') {
        "osx-$Architecture.tar.gz"
    } else {
        throw "Unsupported operating system: $OS"
        return
    }

    # Set the URL and output filename for the latest release
    $ZipUrl = ($Response.Links | Where-Object { $_.href -match $Pattern }).href
    $OutputPath = [System.IO.Path]::Combine($HOME, 'Downloads', "PowerShell-latest.${Pattern}")

    try {
        Invoke-WebRequest -Uri $ZipUrl -OutFile $OutputPath -
    } catch {
        Write-Output "PowerShell has been downloaded to $OutputPath"
    }

} # end function Get-PowerShellPortable
