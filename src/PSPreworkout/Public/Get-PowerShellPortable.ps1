function Get-PowerShellPortable {
    <#
    .SYNOPSIS
    Download a portable version of PowerShell to run anywhere on demand.

    .DESCRIPTION
    This function helps you download a zipped copy of the latest version of PowerShell that can be run without needing to install it.

    .PARAMETER Path
    The directory path to download the PowerShell zip or tar.gz file into. Do not include a filename for the download.

    .PARAMETER Extract
    Extract the file after downloading.

    .EXAMPLE
    Get-PowerShellPortable -Path $HOME -Extract

    Download the latest ZIP/TAR of PowerShell to your $HOME folder. It will be extracted into a folder that matches the filename of the compressed archive.
    #>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-PowerShellPortable')]
    [Alias('Get-PSPortable')]
    param (
        # The directory path to download the PowerShell zip or tar.gz file into. Do not include a filename for the download.
        [Parameter()]
        [string]
        $Path,

        # Extract the file after downloading.
        [Parameter()]
        [switch]
        $Extract
    )

    # Send non-identifying usage statistics to PostHog.
    Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

    #region Determine Download Uri
    $DownloadLinks = (Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest').assets.browser_download_url

    # Can use [System.Runtime.InteropServices.RuntimeInformation]::RuntimeIdentifier for simpler platform targeting, but it may not be available in older PowerShell versions.
    # Determine the platform and architecture
    $RuntimeInfo = [System.Runtime.InteropServices.RuntimeInformation]

    $Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    # OSArchitecture isn't present in older versions of .NET Framework, so use the environment variable as a fallback for Windows.
    if (-not $Architecture) { $Architecture = $([System.Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE')).Replace('AMD64', 'X64') }

    # Set the pattern for the ZIP file based on the OS and architecture
    $FilePattern =
    if ( $RuntimeInfo::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows) ) {
        "win-$Architecture.zip"
    } elseif ( $RuntimeInfo::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux) ) {
        "linux-$Architecture.tar.gz"
    } elseif ( $RuntimeInfo::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX) ) {
        "osx-$Architecture.tar.gz"
    } else {
        Write-Error "Operating system unknown: $($PSVersionTable.OS)."
        return
    }

    $DownloadUrl = $DownloadLinks | Where-Object { $_ -match $FilePattern }
    $FileName = ($DownloadUrl -split '/')[-1]

    if (-not $PSBoundParameters.ContainsKey('Path')) {
        $Path = [System.IO.Path]::Combine($HOME, 'Downloads')
    } else {
        # Resolves an issue with ~ not resolving properly in the script during the file extraction steps.
        $Path = Resolve-Path $Path
    }

    $OutFilePath = [System.IO.Path]::Combine($Path, $FileName)
    $PwshDirectory = "$([System.IO.Path]::GetFileNameWithoutExtension($OutFilePath) -replace '\.tar$', '')"
    if (-not (Test-Path (Join-Path -Path $Path -ChildPath $PwshDirectory))) {
        try {
            New-Item -Name $PwshDirectory -Path $Path -ItemType Directory
        } catch {
            Write-Warning "Unable to create the directory $PwshDirectory in $Path."
        }
    }
    $PwshPath = Join-Path -Path $Path -ChildPath $PwshDirectory
    #endregion Determine Download Uri

    #region Download PowerShell
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $OutFilePath
        Write-Information -MessageData "PowerShell has been downloaded to $OutFilePath."
    } catch {
        Write-Error "Failed to download $DownloadUrl to $Path."
        $_
        return
    }
    #endregion Download PowerShell

    if ($IsWindows -or (-not $IsLinux -and -not $IsMacOS)) {
        Unblock-File -Path $OutFilePath
    }

    #region Extract PowerShell
    if ($PSBoundParameters.ContainsKey('Extract')) {

        if ($IsLinux -or $IsMacOS) {
            # Decompress the GZip file
            $GZipFile = $OutFilePath
            $TarFile = $GZipFile -replace '\.gz$', ''

            $SourceStream = [System.IO.FileStream]::new($GZipFile, [System.IO.FileMode]::Open)
            $TargetStream = [System.IO.FileStream]::new($TarFile, [System.IO.FileMode]::Create)
            try {
                $GZipStream = [System.IO.Compression.GzipStream]::new($SourceStream, [System.IO.Compression.CompressionMode]::Decompress)
                $GZipStream.CopyTo($TargetStream)
            } finally {
                $GZipStream?.Dispose()
                $TargetStream?.Dispose()
                $SourceStream?.Dispose()
            }

            # Use tar command to extract the .tar file
            tar -xf $TarFile -C $PwshPath
            Write-Information -MessageData "PowerShell has been extracted to $PwshPath." -InformationAction Continue
        }

        if (-not $IsLinux -and -not $IsMacOS) {
            # Windows
            try {
                # Expand the zip file into a folder that matches the zip filename without the zip extension
                if (Test-Path -PathType Container -Path (Join-Path -Path $Path -ChildPath $PwshDirectory)) {
                    Expand-Archive -Path $OutFilePath -DestinationPath (Join-Path -Path $Path -ChildPath $PwshDirectory) -Force
                    Write-Information -MessageData "PowerShell has been extracted to $PwshPath" -InformationAction Continue
                    Write-Information -MessageData "Run '$PwshPath\pwsh.exe' to launch the latest version of PowerShell without installing it!" -InformationAction Continue
                } else {
                    Write-Warning -Message "The target folder $Path\$PwshDirectory does not exist." -WarningAction Stop
                }
            } catch {
                Write-Error "Failed to expand the archive $OutFilePath."
                $_
            }
        }

    } # end if Extract
    #endregion Extract PowerShell

} # end function Get-PowerShellPortable
