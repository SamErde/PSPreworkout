function Get-PowerShellPortable {
    <#
        .SYNOPSIS
        Download a portable version of PowerShell to run anywhere on demand.

        .DESCRIPTION
        This function helps you download a zipped version of PowerShell 7.x that can be run anywhere without needing to install it.

        .PARAMETER Path
        The path (directory) to download the PowerShell zip or tar.gz file into. Do not include a filename for the download.

        .PARAMETER Extract
        Extract the downloaded file.

        .EXAMPLE
        Get-PowerShellPortable -Path $HOME -Extract

        Download the latest ZIP/TAR of PowerShell to your $HOME folder. It will be extracted into a folder that matches the filename of the compressed archive.

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

    #region Determine Download Uri
    # Get the zip and tar.gz PowerShell download links for Windows, macOS, and Linux.
    $ApiUrl = 'https://api.github.com/repos/PowerShell/PowerShell/releases/tags/v7.4.5'
    $Response = Invoke-RestMethod -Uri $ApiUrl -Headers @{ 'User-Agent' = 'PowerShellScript' }
    $Assets = $Response.assets
    $DownloadLinks = $Assets | Where-Object { $_.browser_download_url -match '\.zip$|\.tar\.gz$' } | Select-Object -ExpandProperty browser_download_url

    # Determine the platform and architecture
    $Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture

    # Set the pattern for the ZIP file based on the OS and architecture
    $FilePattern = if ( [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows) ) {
        "win-$Architecture.zip"
    } elseif ( [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux) ) {
        "linux-$Architecture.tar.gz"
    } elseif ( [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX) ) {
        "osx-$Architecture.tar.gz"
    } else {
        throw "Operating system unknown: $($PSVersionTable.OS)."
        return
    }

    $DownloadUrl = $DownloadLinks | Where-Object { $_ -match $FilePattern }
    $FileName = ($DownloadUrl -split '/')[-1]

    if (-not $PSBoundParameters.ContainsKey('Path')) {
        $Path = [System.IO.Path]::Combine($HOME)
    }
    $OutFilePath = [System.IO.Path]::Combine($Path, $FileName)
    $PwshDirectory = "$([System.IO.Path]::GetFileNameWithoutExtension($OutFilePath) -replace [Regex]'\.zip$|\.tar.gz$|\.gz$|\.tar$', '')"
    try {
        New-Item -Name $PwshDirectory -Path $Path -ItemType Directory
    } catch {
        Write-Warning "Unable to create the directory $PwshDirectory in $Path."
    }
    #endregion Determine Download Uri

    #region Download PowerShell
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $OutFilePath
        Write-Output "PowerShell has been downloaded to $OutFilePath."
    } catch {
        Write-Error "Failed to download $DownloadUrl to $Path."
        $_
        return
    }
    #endregion Download PowerShell

    #region Extract PowerShell
    if ($PSBoundParameters.ContainsKey('Extract')) {

        if ($IsLinux) {
            # Decompress the .gz file
            $GZipFile = $OutFilePath
            $TarFile = $GZipFile -replace '\.gz$', ''
            [System.IO.Compression.GzipStream]::new(
                [System.IO.FileStream]::new($GZipFile, [System.IO.FileMode]::Open),
                [System.IO.Compression.CompressionMode]::Decompress
            ).CopyTo(
                [System.IO.FileStream]::new($TarFile, [System.IO.FileMode]::Create)
            )
            # Use tar command to extract the .tar file
            tar -xf $tarFile -C "./$PwshDirectory"
        }

        if ($IsMacOS) {
            # You're next...but maybe the Linux code also works here?
            # Decompress the .gz file
            $GZipFile = $OutFilePath
            $TarFile = $GZipFile -replace '\.gz$', ''
            [System.IO.Compression.GzipStream]::new(
                [System.IO.FileStream]::new($GZipFile, [System.IO.FileMode]::Open),
                [System.IO.Compression.CompressionMode]::Decompress
            ).CopyTo(
                [System.IO.FileStream]::new($TarFile, [System.IO.FileMode]::Create)
            )
            # Use tar command to extract the .tar file
            tar -xf $tarFile -C "./$PwshDirectory"
        }

        if (-not $IsLinux -and -not $IsMacOS) {
            # Windows
            try {
                # Expand the zip file into a folder that matches the zip filename without the zip extenstion
                if (Test-Path -PathType Container -Path (Join-Path -Path $Path -ChildPath $PwshDirectory)) {
                    Expand-Archive -Path $OutFilePath -DestinationPath (Join-Path -Path $Path -ChildPath $PwshDirectory) -Force
                    Write-Information -MessageData "PowerShell has been extracted to $Path" -InformationAction Continue
                    Write-Information -MessageData "Run '$Path\pwsh.exe' to launch the latest version of PowerShell without installing it!" -InformationAction Continue
                } else {
                    Write-Warning -Message "The target folder $Path\$Pwshdirectory does not exist." -WarningAction Stop
                }
            } catch {
                Write-Error "Failed to expand the archive $OutFilePath."
                $_
            }
        }

    } # end if Extract
    #endregion Extract PowerShell

} # end function Get-PowerShellPortable
