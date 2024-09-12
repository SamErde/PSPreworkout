function Get-PowerShellPortable {
    <#
        .SYNOPSIS
        Download a portable version of PowerShell 7x to run anywhere on demand.

        .DESCRIPTION
        This function helps you download a zipped version of PowerShell 7.x that can be run anywhere without needing to install it.

        .PARAMETER Path
        Path of the directory to download the PowerShell zip or tar.gz file into.

        .PARAMETER Extract
        Extract the downloaded file.

        .EXAMPLE
        Get-PowerShellPortable -Path .\ -Extract

    #>

    [CmdletBinding()]
    [Alias('Get-PSPortable')]
    param (
        # Path to download and extract PowerShell to
        [Parameter()]
        [string]
        $Path,

        # Extract the file after downloading
        [Parameter()]
        [switch]
        $Extract
    )

    # Get the zip and tar.gz PowerShell download links for Windows, macOS, and Linux.
    $ApiUrl = 'https://api.github.com/repos/PowerShell/PowerShell/releases/tags/v7.4.5'
    $Response = Invoke-RestMethod -Uri $ApiUrl -Headers @{ 'User-Agent' = 'PowerShellScript' }
    $Assets = $Response.assets
    $DownloadLinks = $Assets | Where-Object { $_.browser_download_url -match '\.zip$|\.tar\.gz$' } | Select-Object -ExpandProperty browser_download_url

    # Determine the platform and architecture
    $Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture

    # Set the pattern for the ZIP file based on the OS and architecture
    $OS = if ( [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows) ) {
        'win'
    } elseif ( [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux) ) {
        'linux'
    } elseif ( [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX) ) {
        'osx'
    } else {
        throw "Operating system unknown: $($PSVersionTable.OS)."
        return
    }

    $FilePattern = "$OS-$Architecture"
    $DownloadUrl = $DownloadLinks | Where-Object { $_ -match $FilePattern }
    $FileName = ($DownloadUrl -split '/')[-1]

    if (-not $PSBoundParameters.ContainsKey('Path')) {
        $Path = [System.IO.Path]::Combine($HOME, 'Downloads')
    }
    $OutFilePath = [System.IO.Path]::Combine($Path, $FileName)

    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $OutFilePath
        Write-Output "PowerShell has been downloaded to $OutFilePath."
    } catch {
        Write-Error "Failed to download $DownloadUrl to $Path."
        $_
        return
    }

    if ($PSBoundParameters.ContainsKey('Extract')) {
        try {
            Expand-Archive -Path $OutFilePath -Force
            $FolderSegments = $OutFilePath.Split('.')
            $Folder = $FolderSegments[0..($FolderSegments.Length - 2)] -join '.'
            Write-Information -MessageData "PowerShell has been extracted to $Folder" -InformationAction Continue
            Write-Information -MessageData "Run '$Folder\pwsh.exe' to launch the latest version of PowerShell without installing it!" -InformationAction Continue
        } catch {
            Write-Error "Failed to expand the archive $OutFilePath."
            $_
        }
    }
} # end function Get-PowerShellPortable
