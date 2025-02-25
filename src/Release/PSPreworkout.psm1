# This is a locally sourced Imports file for local development.
# It can be imported by the psm1 in local development to add script level variables.
# It will merged in the build process. This is for local development only.

# region Script Variables
# $script:resourcePath = "$PSScriptRoot\Resources"
Export-ModuleMember -Alias *


function Edit-PSReadLineHistoryFile {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Edit-PSReadLineHistoryFile')]
    [Alias('Edit-HistoryFile')]
    param (

    )

    begin {
        $HistoryFilePath = (Get-PSReadLineOption).HistorySavePath
    } # end begin block

    process {
        if ((Get-Command code)) {
            # Open the file in Visual Studio Code if code found
            code $HistoryFilePath

            <#
            if ((Get-Command node -ErrorAction SilentlyContinue)) {
                # Use the Visual Studio Code API to set the open file's language (this portion rendered by AI).
                $VSCodeScript = @'
const vscode = require('vscode');

function setLanguage(uri, language) {
    vscode.workspace.openTextDocument(uri).then(document => {
        vscode.window.showTextDocument(document).then(() => {
            vscode.languages.setTextDocumentLanguage(document, language);
        });
    });
}

const uri = vscode.Uri.file(process.argv[2]);
setLanguage(uri, 'powershell');
'@ # End VSCodeScript (this portion rendered by AI)

                # Save the VS Code script to a temporary file and then run it.
                $TempScriptFile = [System.IO.Path]::GetTempFileName() + '.js'
                Set-Content -Path $TempScriptFile -Value $VSCodeScript -Force
                node $TempScriptFile "`'$HistoryFilePath`'"
            }
#> # End scriptblock to set the file language to 'PowerShell'

        } else {
            # Open the text file with the default file handler if VS Code is not found.
            Start-Process $HistoryFilePath
        }
    } # end process block

    end {
        if ($TempScriptFile) {
            #Remove-Item -Path $TempScriptFile -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        }
    } # end end block

} # end function Edit-PSreadLineHistoryFile



function Edit-WingetSettingsFile {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Edit-WinGetSettingsFile')]
    param (
        # To Do: Add parameters to choose an editor
    )

    begin {
        $WinGetSettingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        if (-not (Test-Path -PathType Leaf -Path $WinGetSettingsFile)) {
            Write-Information -MessageData 'No WinGet configuration file found. Creating a new one.' -InformationAction Continue
        }
    } # end begin block

    process {
        if ( (Get-Command code -ErrorAction SilentlyContinue) ) {
            code $WinGetSettingsFile
        } elseif ( (Get-Command notepad -ErrorAction SilentlyContinue) ) {
            notepad $WinGetSettingsFile
        } elseif ((Get-AppxPackage -Name 'Microsoft.WindowsNotepad' -ErrorAction SilentlyContinue)) {
            Start-Process "shell:AppsFolder\$(Get-StartApps -Name 'Notepad' | Select-Object -ExpandProperty AppId)" $WinGetSettingsFile
        } elseif (Get-Command 'powershell_ise.exe' -ErrorAction SilentlyContinue) {
            powershell_ise $WinGetSettingsFile
        } else {
            Write-Warning -Message 'No editors were found. You might want to install Visual Studio Code, Notepad, or Notepad++.'
        }
    } # end process block

    end {
        # end
    }
} # end function Edit-WinGetSettingsFile



function Get-EnvironmentVariable {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [Alias('gev')]
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-EnvironmentVariable')]
    [OutputType('System.Collections.Generic.List[PSObject]')]
    param (
        # The name of the environment variable to retrieve. If not specified, all environment variables are returned.
        [Parameter(Position = 0)]
        #[Parameter(Position = 0, ParameterSetName = 'LookupByName')]
        [string]$Name,

        # A regex pattern to search variable names by
        [Parameter()]
        #[Parameter(Position = 0, ParameterSetName = 'LookupByRegexPattern')]
        [string]
        $Pattern,

        # The target of the environment variable to retrieve: Process (default), User, or Machine.
        [Parameter()]
        [System.EnvironmentVariableTarget[]]
        $Target,

        # Switch to show environment variables in all target scopes.
        [Parameter()]
        [switch]
        $All
    )

    begin {
        # Initialize the collection of environment variables that will be returned to the pipeline at the end.
        [System.Collections.Generic.List[PSObject]]$EnvironmentVariables = @()

        # Get environment variables from all targets if no parameters are specified
        if (
            'Name' -notin $PSBoundParameters.Keys -and
            'Pattern' -notin $PSBoundParameters.Keys -and
            'Target' -notin $PSBoundParameters.Keys
        ) {
            $All = $true
            $Target = @([System.EnvironmentVariableTarget]::Process, [System.EnvironmentVariableTarget]::User, [System.EnvironmentVariableTarget]::Machine)
        }

        # If a Name or a Pattern is specified with no Target, get the name/pattern matches from all targets.
        if ( ( $PSBoundParameters.ContainsKey('Name') -or $PSBoundParameters.ContainsKey('Pattern') ) -and
            -not $PSBoundParameters.ContainsKey('Target')
        ) {
            $Target = @('Process', 'User', 'Machine')
        }

        # Handle -All when used with or without a name, pattern, or target parameter
        if ( $PSBoundParameters.ContainsKey('All') ) {

            # Get all matches for a specific name or pattern
            if ( $PSBoundParameters.ContainsKey('Name') -or $PSBoundParameters.ContainsKey('Pattern') ) {
                # Don't need to change anything (yet?)
            }

            # Get all variables from a specific target if a name or pattern are not specified
            if ( $PSBoundParameters.ContainsKey('Target') -and
                -not ( $PSBoundParameters.ContainsKey('Name') -or $PSBoundParameters.ContainsKey('Pattern') )
            ) {
                # Don't change the target. Don't need to do anything here?
            }

        }
        Write-Debug -Message "Parameters: $($PSBoundParameters.GetEnumerator())`n`n`t   Name: $Name`n`tPattern: $Pattern`n`t Target: $Target`n`t    All: $All" -ErrorAction SilentlyContinue
    } # end begin block

    process {
        foreach ($thisTarget in $Target) {

            if ( $PSBoundParameters.ContainsKey('Name') -and -not $PSBoundParameters.ContainsKey('Pattern') ) {
                # If a variable name was specified, get that environment variable.
                # Temporarily using this -and -not condition because I couldn't get exclusive Name/Pattern parameter sets to work.
                $ThisEnvironmentVariable = [ordered]@{
                    Name        = $Name
                    Value       = [Environment]::GetEnvironmentVariable($Name, $thisTarget)
                    Target      = $thisTarget[0]
                    PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                    ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                }
                $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                $EnvironmentVariables.Add($item)

            } elseif ( $PSBoundParameters.ContainsKey('Pattern') ) {
                if ($Name) {
                    Write-Verbose -Message 'A value for the Name parameter was specified, but it is being ignored because a Pattern was also provided.'
                }
                # If a pattern is specified, get environment variables with names that match the pattern.
                $Result = [Environment]::GetEnvironmentVariables($thisTarget).GetEnumerator() | Where-Object { $_.Key -match $pattern }
                foreach ($PatternResult in $Result) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $PatternResult.Name
                        Value       = $PatternResult.Value
                        Target      = $thisTarget[0]
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                }

            } elseif ( $PSBoundParameters.ContainsKey('Target') -and
                -not ( $PSBoundParameters.ContainsKey('Name') -or $PSBoundParameters.ContainsKey('Pattern') )
            ) {
                foreach ( $ev in ([Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$thisTarget)).GetEnumerator() ) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $ev.Name
                        Value       = $ev.Value
                        Target      = $thisTarget
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                }

            } else {
                # Get all environment variables.
                foreach ( $ev in ([Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$thisTarget).GetEnumerator()) ) {
                    $ThisEnvironmentVariable = [ordered]@{
                        Name        = $ev.Name
                        Value       = $ev.Value
                        Target      = $thisTarget[0]
                        PID         = if ($thisTarget -eq 'Process') { $PID } else { $null }
                        ProcessName = if ($thisTarget -eq 'Process') { (Get-Process -Id $PID).Name } else { $null }
                    }
                    $item = New-Object -TypeName PSObject -Property $ThisEnvironmentVariable
                    $EnvironmentVariables.Add($item)
                }
            }
        } # end foreach target
    } # end process block

    end {
        $EnvironmentVariables
    } # end end block
} # end function



function Get-LoadedAssembly {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-LoadedAssembly')]
    [OutputType('Object[]')]

    [Alias('Get-Assembly')]
    param ()

    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName
}



function Get-PowerShellPortable {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-PowerShellPortable')]
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
    $DownloadLinks = (Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest').assets.browser_download_url

    # Determine the platform and architecture
    $Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    # OSArchitecture isn't present in older versions of .NET Framework, so use the environment variable as a fallback for Windows.
    if (-not $Architecture) { $Architecture = $([System.Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE')).Replace('AMD64', 'X64') }

    # Set the pattern for the ZIP file based on the OS and architecture
    $FilePattern =
    if ( [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows) ) {
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
        $Path = [System.IO.Path]::Combine($HOME, 'Downloads')
    } else {
        # Resolves an issue with ~ not resolving properly in the script during the file extraction steps.
        $Path = Resolve-Path $Path
    }

    $OutFilePath = [System.IO.Path]::Combine($Path, $FileName)
    $PwshDirectory = "$([System.IO.Path]::GetFileNameWithoutExtension($OutFilePath) -replace [Regex]'\.zip$|\.tar.gz$|\.gz$|\.tar$', '')"
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
        Write-Output "PowerShell has been downloaded to $OutFilePath."
    } catch {
        Write-Error "Failed to download $DownloadUrl to $Path."
        $_
        return
    }
    #endregion Download PowerShell

    Unblock-File -Path $OutFilePath

    #region Extract PowerShell
    if ($PSBoundParameters.ContainsKey('Extract')) {

        if ($IsLinux) {
            # Decompress the GZip file
            $GZipFile = $OutFilePath
            $TarFile = $GZipFile -replace '\.gz$', ''
            [System.IO.Compression.GzipStream]::new(
                [System.IO.FileStream]::new($GZipFile, [System.IO.FileMode]::Open),
                [System.IO.Compression.CompressionMode]::Decompress
            ).CopyTo(
                [System.IO.FileStream]::new($TarFile, [System.IO.FileMode]::Create)
            )
            # Use tar command to extract the .tar file
            tar -xf $tarFile -C $PwshPath
            Write-Output "PowerShell has been extracted to $PwshPath."
        }

        if ($IsMacOS) {
            # Decompress the tar and GZip file
            $GZipFile = $OutFilePath
            $TarFile = $GZipFile -replace '\.gz$', ''
            [System.IO.Compression.GzipStream]::new(
                [System.IO.FileStream]::new($GZipFile, [System.IO.FileMode]::Open),
                [System.IO.Compression.CompressionMode]::Decompress
            ).CopyTo(
                [System.IO.FileStream]::new($TarFile, [System.IO.FileMode]::Create)
            )
            # Use tar command to extract the .tar file
            tar -xzf $GzipFile -C $PwshPath
            Write-Output "PowerShell has been extracted to $PwshPath."
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



function Get-TypeAccelerator {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Get-TypeAccelerator')]
    [OutputType('Object[]')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Fighting with VS Code autoformatting.')]
    param (

        # Parameter help description
        [Parameter(Position = 0, HelpMessage = 'The name of the type accelerator, such as "ADSI."')]
        [SupportsWildcards()]
        [string]
        $Name = '*'
    )

    $TypeAccelerators = ([PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get).GetEnumerator() |
        Where-Object { $_.Key -like $Name } |
            ForEach-Object {
                # Create a custom object to store the type name and the type itself.
                [PSCustomObject]@{
                    PSTypeName = 'PSTypeAccelerator'
                    PSVersion  = $PSVersionTable.PSVersion
                    Name       = $_.Key
                    Type       = $_.Value.FullName
                }
            }
    $TypeAccelerators
}



function Initialize-PSEnvironmentConfiguration {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Initialize-PSEnvironmentConfiguration')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Argument completers are weird.')]
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
        # Suppress PSScriptAnalyzer Errors
        $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null

    }

    process {
        #region Configure Git
        if ($PSBoundParameters.ContainsKey('Name')) { git config --global user.name $Name }
        if ($PSBoundParameters.ContainsKey('Email')) { git config --global user.email $Email }
        #endregion Configure Git


        #region Install PowerShell modules
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        if ($Modules -and -not $SkipModules.IsPresent) {
            foreach ($module in $Modules) {
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
        # Update Pester and ignore the publisher warning
        Install-Module -Name Pester -Repository PSGallery -SkipPublisherCheck -AllowClobber -Force
        #endregion Install PowerShell modules


        #region Default Settings, All Versions
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


        #region Install Packages
        # Install packages
        if ($Packages -and -not $SkipPackages.IsPresent) {
            foreach ($package in $Packages) {
                try {
                    Write-Verbose "Installing package: $package."
                    winget install --id $package --accept-source-agreements --accept-package-agreements --source winget --scope user --silent
                } catch {
                    $_
                }
            }
        }
        #endregion Install Packages

        #region Windows Terminal
        $KeyPath = 'HKCU:\Console\%%Startup'
        if (-not (Test-Path -Path $keyPath)) {
            New-Item -Path $KeyPath | Out-Null
        } else {
            Write-Verbose -Message "Key already exists: $KeyPath"
        }

        # Set Windows Terminal as the default terminal application if it is installed on this system.
        if (Test-Path -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe" -PathType Leaf) {
            # Set Windows Terminal as the default terminal application for Windows.
            New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Force | Out-Null
            New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Force | Out-Null
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    [System.Drawing.Text.InstalledFontCollection]::new().Families |
        Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
            ForEach-Object { "'$($_.Name)'" }

    # Suppress PSScriptAnalyzer Errors
    $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null
}



function Install-CommandNotFoundUtility {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    #requires -version 7.4
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Install-CommandNotFoundUtility')]
    param (
    )

    begin {
    } # end begin block

    process {
        try {
            Install-Module -Name Microsoft.WinGet.CommandNotFound -Scope CurrentUser -Force
        } catch {
            throw $_
        }
        try {
            # Might need to  remove this to avoid errors during PSPreworkout installation.
            Import-Module -Name Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
        } catch [System.InvalidOperationException] {
            Write-Warning -Message "Received the error `"$_`" while importing the 'Microsoft.WinGet.CommandNotFound module. The module may have already been installed and imported in the current session. This can usually be ignored.`n"
        } # end try/catch block

        # To Do: Check if already enabled:
        Enable-ExperimentalFeature -Name 'PSFeedbackProvider'
        Enable-ExperimentalFeature -Name 'PSCommandNotFoundSuggestion'
    } # end process block

    end {
        Write-Information -MessageData "`nThe WinGetCommandNotFound utility has been installed. Be sure to add it to your PowerShell profile with `Import-Module Microsoft.WinGet.CommandNotFound`.`n`nYou may also run <https://github.com/microsoft/PowerToys/blob/main/src/settings-ui/Settings.UI/Assets/Settings/Scripts/EnableModule.ps1> to perform this step automatically.`n" -InformationAction Continue
    } # end end block

} # end function Install-CommandNotFoundUtility



function Install-OhMyPosh {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Install-OhMyPosh')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Justification = 'Invoke-Expression is used for online OMP installer.')]
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

    switch ($Method) {
        chocolatey {
            if (choco.exe) {
                choco install oh-my-posh
            } else {
                Write-Error -Message 'Chocolatey was not found. Please install it or try another method.' -ErrorAction Stop
            }
        }
        winget {
            # Install Oh My Posh using Winget
            if (winget.exe) {
                winget install --id JanDeDobbeleer.OhMyPosh --source $WingetSource
            } else {
                $Response = Read-Host -Prompt 'Winget was not found. Would you like to try to install it?'
                if ($Response -eq 'y' -or $Response -eq 'yes') {
                    try {
                        $progressPreference = 'silentlyContinue'
                        Write-Information 'Downloading WinGet and its dependencies...'
                        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
                        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
                        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
                        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
                        Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
                        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

                        if (winget.exe) {
                            winget install --id JanDeDobbeleer.OhMyPosh --source $WingetSource
                        }
                    } catch {
                        Write-Error -Message 'Sorry, we failed to download and install winget. Please refer to https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget.'
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
            Write-Debug 'Not installing a nerd fonts'
        }
        True {
            if ($Font -eq 'Default' -or $Fond -eq 'Meslo') {
                $FontName = 'Meslo'
            } else {
                $FontName = $null
            }

            Write-Information -MessageData "Installing as current user to avoid requiring local admin rights. Please see notes at https://ohmyposh.dev/docs/installation/fonts. `n" -InformationAction Continue
            oh-my-posh font install $FontName --user
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

    oh-my-posh init pwsh | Invoke-Expression
}



function Install-PowerShellISE {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Install-PowerShellISE')]
    param ()

    # Check if running as admin
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Error 'This script must be run as an administrator.'
        return
    }

    $OSCaption = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption

    # Quick check to see if running on Windows.
    if (-not $OSCaption -match 'Windows') {
        Write-Error 'This script is only for Windows OS.'
        return
    }

    # Check if running a Windows client or Windows Server OS
    if ($OSCaption -match 'Windows Server') {

        # Windows Server OS
        if ((Get-WindowsFeature -Name PowerShell-ISE -ErrorAction SilentlyContinue).Installed) {
            Write-Output 'The Windows PowerShell ISE is already installed on this Windows Server.'
        } else {
            Import-Module ServerManager
            Add-WindowsFeature PowerShell-ISE
        }

    } else {

        # Windows client OS
        if ((Get-WindowsCapability -Name 'Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0' -Online).State -eq 'Installed') {
            Write-Output 'The Windows PowerShell ISE is already installed.'
        } else {
            # Resetting the Windows Update source sometimes resolves errors when trying to add Windows capabilities
            $CurrentWUServer = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' | Select-Object -ExpandProperty UseWUServer
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' -Value 0
            Restart-Service wuauserv

            try {
                Get-WindowsCapability -Name Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0 -Online | Add-WindowsCapability -Online -Verbose
            } catch {
                Write-Error "There was a problem adding the Windows PowerShell ISE: $error"
            }

            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'UseWUServer' -Value $CurrentWUServer
            Restart-Service wuauserv
        }
    } # end OS type check

} # end function Install-PowerShellISE



function Install-WinGet {
    <#
.EXTERNALHELP PSPreworkout-help.xml
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



function New-Credential {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/New-Credential')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    [OutputType('System.Management.Automation.PSCredential')]
    param ()

    Write-Output 'Create a Credential'
    $User = Read-Host -Prompt 'User'
    $Password = Read-Host "Password for user $User" -AsSecureString
    $Credential = [System.Management.Automation.PSCredential]::New($User, $Password)
    $Credential
} # end function New-Credential



function New-ScriptFromTemplate {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/New-ScriptFromTemplate')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    #[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Making it pretty.')]
    [Alias('New-Script')]
    param (
        # The name of the new function.
        [Parameter(Mandatory, ParameterSetName = 'Named', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # The verb to use for the function name.
        [Parameter(Mandatory, ParameterSetName = 'VerbNoun', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Verb,

        # The noun to use for the function name.
        [Parameter(Mandatory, ParameterSetName = 'VerbNoun', Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Noun,

        # Synopsis of the new function.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Synopsis,

        # Description of the new function.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        # Optional alias for the new function.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Alias,

        # Name of the author of the script
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Author = (Get-CimInstance -ClassName Win32_UserAccount -Filter "Name = `'$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1])`'").FullName,

        # Parameter name(s) to include
        #[Parameter()]
        #[ValidateNotNullOrEmpty()]
        #[string[]]
        #$Parameter,

        # Path of the directory to save the new function in.
        [Parameter()]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]
        $Path,

        # Optionally skip name validation checks.
        [Parameter()]
        [switch]
        $SkipValidation
    )

    if ($PSBoundParameters.ContainsKey('Verb') -and -not $SkipValidation -and $Verb -notin (Get-Verb).Verb) {
        Write-Warning "`"$Verb`" is not an approved verb. Please run `"Get-Verb`" to see a list of approved verbs."
        break
    }

    if ($PSBoundParameters.ContainsKey('Verb') -and $PSBoundParameters.ContainsKey('Noun')) {
        $Name = "$Verb-$Noun"
    }

    if ($PSBoundParameters.ContainsKey('Name') -and -not $SkipValidation -and
        $Name -match '\w-\w' -and $Name.Split('-')[0] -notin (Get-Verb).Verb ) {
        Write-Warning "It looks like you are not using an approved verb: `"$($Name.Split('-')[0]).`" Please run `"Get-Verb`" to see a list of approved verbs."
    }

    # Set the script path and filename. Use current directory if no path specified.
    if (Test-Path -Path $Path -PathType Container) {
        $ScriptPath = [System.IO.Path]::Combine($Path, "$Name.ps1")
    } else {
        $ScriptPath = ".\$Name.ps1"
    }

    # Create the function builder string builder and function body string.
    $FunctionBuilder = [System.Text.StringBuilder]::New()
    $FunctionBody = (Get-Content -Path "$PSScriptRoot\ScriptTemplate.txt" -Raw)

    # Replace template placeholders with strings from parameter inputs.
    $FunctionBody = $FunctionBody -Replace 'New-Function', $Name
    $FunctionBody = $FunctionBody -Replace '__SYNOPSIS__', $Synopsis
    $FunctionBody = $FunctionBody -Replace '__DESCRIPTION__', $Description
    $FunctionBody = $FunctionBody -Replace '__DATE__', (Get-Date -Format 'yyyy-MM-dd')
    $FunctionBody = $FunctionBody -Replace '__AUTHOR__', $Author
    # Set an alias for the new function if one is given in parameters.
    if ($PSBoundParameters.ContainsKey('Alias')) {
        $FunctionBody = $FunctionBody -Replace '__ALIAS__', "[Alias(`'$Alias`')]"
    } else {
        $FunctionBody = $FunctionBody -Replace '__ALIAS__', ''
    }

    # Create the new file.
    [void]$FunctionBuilder.Append($FunctionBody)
    $FunctionBuilder.ToString() | Out-File -FilePath $ScriptPath -Encoding utf8 -Force

} # end function New-ScriptFromTemplate



function Out-JsonFile {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Out-JsonFile')]
    param (
        # The object to convert to JSON.
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        # [ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_) -and -not [string]::IsNullOrEmpty($_)) { $true } })]
        [Object]
        $Object,

        # Depth to serialize the object into JSON. Default is 2.
        [Parameter()]
        [Int32]
        $Depth = 2,

        # Full path and filename to save the JSON to.
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        # [ValidatePattern('\.json$')] # Do not require a JSON extension.
        [ValidateScript({
                if ((Split-Path -Path $_).Length -gt 0) {
                    if (Test-Path -Path (Split-Path -Path $_) -PathType Container) {
                        $true
                    } else {
                        throw "The directory `'$(Split-Path -Path $_)`' was not found."
                    }
                } else { $true }
            })]
        [string]
        $FilePath
    )

    begin {
        # Validate the file path and extension.
        if ($FilePath) {
            # Ensure that a working directory is included in filepath.
            if ([string]::IsNullOrEmpty([System.IO.Path]::GetDirectoryName($FilePath))) {
                $FilePath = Join-Path -Path (Get-Location -PSProvider FileSystem).Path -ChildPath $FilePath
            }

            # To Do: Check for a bare directory path and add a filename to it.

            $OutFile = $FilePath

        } else {
            # If $FilePath is not specified then set $Path to the current location of the FileSystem provider.
            [string]$Path = (Get-Location -PSProvider FileSystem).Path

            # Set the file name to be the same as the name of the object passed in the first parameter (providing it has a name).
            $ObjectName = "$($PSCmdlet.MyInvocation.Statement.Split('$')[1])"
            if ([string]::IsNullOrEmpty($ObjectName)) {
                # Just name the file "Object.json" if no filename or object name is present.
                $OutFile = Join-Path -Path $Path -ChildPath 'Object.json'
            } else {
                $OutFile = Join-Path -Path $Path -ChildPath "${ObjectName}.json"
            }
        }
    } # end begin block

    process {
        $Object | ConvertTo-Json -Depth $Depth | Out-File -FilePath $OutFile -Force
    } # end process block

    end {
        Remove-Variable Object, FilePath, Path, OutFile -ErrorAction SilentlyContinue
    } # end end block
}



function Set-ConsoleFont {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Set-ConsoleFont')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Argument completers are weird.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param (
        [Parameter(Mandatory = $true)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                [System.Drawing.Text.InstalledFontCollection]::new().Families |
                    Where-Object { $_.Name -match 'Mono|Courier|Consolas|Fixed|Console|Terminal|Nerd Font|NF[\s|\b]|NFP' } |
                        ForEach-Object { "'$($_.Name)'" }
            })]
        [string]$Font
    )
    # Suppress PSScriptAnalyzer Errors
    $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null

    # Your logic to set the console font goes here
    Write-Output "Setting console font to $Font."

    if ($IsLinux -or $IsMacOS) {
        Write-Information 'Setting the font is not yet supported in Linux or macOS.' -InformationAction Continue
        return
    }

    Get-ChildItem -Path 'HKCU:\Console' | ForEach-Object {
        Set-ItemProperty -Path (($_.Name).Replace('HKEY_CURRENT_USER', 'HKCU:')) -Name 'FaceName' -Value $Font
    }
}

# Register the argument completer for Set-ConsoleFont.
Register-ArgumentCompleter -CommandName Set-ConsoleFont -ParameterName Font -ScriptBlock {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Argument completers are weird.')]
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



function Set-DefaultTerminal {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    param (
        # The name of the application to use as the default terminal in Windows.
        [Parameter(Mandatory = $false)]
        [string]$Name = 'WindowsTerminal'
    )

    begin {
        $KeyPath = 'HKCU:\Console\%%Startup'
        if (-not (Test-Path -Path $keyPath)) {
            New-Item -Path $KeyPath | Out-Null
        } else {
            Write-Verbose -Message "Key already exists: $KeyPath"
        }
    } # end begin block

    process {
        switch ($Name) {
            'WindowsTerminal' {
                New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Force | Out-Null
                New-ItemProperty -Path 'HKCU:\Console\%%Startup' -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Force | Out-Null
            }
            default {
                Write-Information -MessageData 'No terminal application was specified.' -InformationAction Continue
            }
        }
    } # end process block

    end {
        Write-Information -MessageData "Default terminal set to: ${Name}." -InformationAction Continue
    } # end end block

} # end function Set-DefaultTerminal



function Set-EnvironmentVariable {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [Alias('sev')]
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Set-EnvironmentVariable')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    param (
        # The name of the environment variable to set.
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        # The value of environment variable to set.
        [Parameter(Mandatory, Position = 1)]
        [string]
        $Value,

        # The target of the environment variable to set.
        [Parameter(Mandatory, Position = 2)]
        [System.EnvironmentVariableTarget]
        $Target
    )

    begin {
        #
    }

    process {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }

    end {
        #
    }
}



function Show-LoadedAssembly {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Show-LoadedAssembly')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    # [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'There is a lot of them.')]
    [Alias('Show-LoadedAssemblies')]
    [OutputType([Object])]
    param (
        # Show a grid view of the loaded assemblies
        [Parameter()]
        [switch]
        $GridView
    )

    $LoadedAssemblies = Get-LoadedAssembly | Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted |
        ForEach-Object {
            # Create a custom object to split out the details of each assembly
            $NameSplit = $_.FullName.Split(',').Trim()
            [PSCustomObject]@{
                Name                = [string]$NameSplit[0]
                Version             = [version]($NameSplit[1].Replace('Version=', ''))
                Location            = [string]$_.Location
                GlobalAssemblyCache = [bool]$_.GlobalAssemblyCache
                IsFullyTrusted      = [bool]$_.IsFullyTrusted
            }
        }

    if ($PSBoundParameters.ContainsKey('GridView')) {

        if ((Get-Command -Name Out-ConsoleGridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Core')) {
            $LoadedAssemblies | Out-ConsoleGridView
        } elseif ((Get-Command -Name Out-GridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Desktop')) {
            $LoadedAssemblies | Out-GridView
        } else {
            Write-Output 'The Out-GridView and Out-ConsoleGridView cmdlets were not found. Please install the Microsoft.PowerShell.ConsoleGuiTools module or re-install the PowerShell ISE if using Windows PowerShell 5.1.'
            $LoadedAssemblies | Format-Table -AutoSize
        }
    }

    $LoadedAssemblies
}



function Show-WithoutEmptyProperty {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Show-WithoutEmptyProperty')]
    [OutputType('PSCustomObject')]
    param (
        # The object to show without empty properties
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Object]
        $Object
    )

    begin {

    }

    process {
        $Object.PSObject.Properties | Where-Object {
            $_.Value
        } | ForEach-Object -Begin {
            $JDHIT = [ordered]@{}
            [void]$JDHIT # Suppress code analyzer errors during build.
        } -Process {
            $JDHIT.Add($_.name, $_.Value)
        } -End {
            New-Object -TypeName PSObject -Property $JDHIT
        }
    }

    end {

    }
}



function Test-IsElevated {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Test-IsElevated')]
    [Alias('isadmin', 'isroot')]
    param ()

    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        $CurrentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
        return $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } else {
        # Must be Linux or OSX, so use the id util. Root has userid of 0.
        return 0 -eq (id -u)
    }
}



function Update-AllTheThings {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(
        SupportsShouldProcess,
        HelpUri = 'https://day3bits.com/PSPreworkout/Update-AllTheThings'
    )]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Update-AllTheThings', Justification = 'This is what we do.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive Use')]
    [Alias('uatt')]
    param (
        # Skip the step that updates PowerShell modules
        [Parameter()]
        [switch]
        $SkipModules,

        # Skip the step that updates PowerShell scripts
        [Parameter()]
        [switch]
        $SkipScripts,

        # Skip the step that updates PowerShell help
        [Parameter()]
        [switch]
        $SkipHelp,

        # Skip the step that updates WinGet packages
        [Parameter()]
        [switch]
        $SkipWinGet,

        # Skip the step that updates Chocolatey packages
        [Parameter()]
        [Alias('Skip-Choco')]
        [switch]
        $IncludeChocolatey
    )

    begin {
        # Spacing to get host output from script, winget, and choco all below the progress bar.
        $Banner = @"
  __  __        __     __         ___   ____
 / / / /__  ___/ /__ _/ /____    / _ | / / /
/ /_/ / _ \/ _  / _ `/ __/ -_)  / __ |/ / /
\____/ .__/\_,_/\_,_/\__/\__/  /_/ |_/_/_/
 ___/_/__         ________   _
/_  __/ /  ___   /_  __/ /  (_)__  ___ ____
 / / / _ \/ -_)   / / / _ \/ / _ \/ _ `(_-<
/_/ /_//_/\__/   /_/ /_//_/_/_//_/\_, /___/
                                 /___/ v0.5.9

"@
        Write-Host $Banner
    } # end begin block

    process {
        Write-Verbose 'Set the PowerShell Gallery as a trusted installation source.'
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        if (Get-Command -Name Set-PSResourceRepository -ErrorAction SilentlyContinue) {
            Set-PSResourceRepository -Name 'PSGallery' -Trusted
        }

        #region UpdatePowerShell

        # ==================== Update PowerShell Modules ====================

        # Update the outer progress bar
        $PercentCompleteOuter = 1
        $ProgressParamOuter = @{
            Id               = 0
            Activity         = 'Update Everything'
            CurrentOperation = 'Getting Installed PowerShell Modules'
            Status           = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete  = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter

        if (-not $SkipModules) {
            # Get all installed PowerShell modules
            Write-Host '[1] Getting Installed PowerShell Modules'
            $Modules = (Get-InstalledModule)
            $ModuleCount = $Modules.Count
            Write-Host "[2] Updating $ModuleCount PowerShell Modules"
        } else {
            Write-Host '[1] Skipping PowerShell Modules'
        }

        # Estimate 10% progress so far and 70% at the next step
        $PercentCompleteOuter_Modules = 10
        [int]$Module_i = 0

        # Update all PowerShell modules
        foreach ($module in $Modules) {
            # Update the module loop counter and percent complete for both progress bars
            ++$Module_i
            [double]$PercentCompleteInner = [math]::ceiling( (($Module_i / $ModuleCount) * 100) )
            [double]$PercentCompleteOuter = [math]::ceiling( $PercentCompleteOuter_Modules + (60 * ($PercentCompleteInner / 100)) )

            # Update the outer progress bar while updating modules
            $ProgressParamOuter = @{
                Id              = 0
                Activity        = 'Update Everything'
                Status          = "Progress: $PercentCompleteOuter`% Complete"
                PercentComplete = $PercentCompleteOuter
            }
            Write-Progress @ProgressParamOuter

            # Update the child progress bar while updating modules
            $ProgressParam1 = @{
                Id               = 1
                ParentId         = 0
                Activity         = 'Updating PowerShell Modules'
                CurrentOperation = "$($module.Name)"
                Status           = "Progress: $PercentCompleteInner`% Complete"
                PercentComplete  = $PercentCompleteInner
            }
            Write-Progress @ProgressParam1

            # Do not update prerelease modules
            if ($module.Version -match 'alpha|beta|prerelease|preview') {
                Write-Information "`t`tSkipping $($module.Name) because a prerelease version is currently installed." -InformationAction Continue
                continue
            }

            # Finally update the current module
            try {
                Update-Module $module.Name
            } catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                # Add a catch for mismatched certificates between module versions.
                Write-Verbose $_
            }
        }

        # ##### Add a section for installed scripts +++++
        if (-not $SkipScripts) {
            Write-Host '[2] Updating PowerShell Scripts'
            Update-Script
        } else {
            Write-Host '[2] Skipping PowerShell Scripts'
        }
        # ##### Add a section for installed scripts +++++

        # Complete the child progress bar after updating modules
        Write-Progress -Id 1 -Activity 'Updating PowerShell Modules' -Completed


        # ==================== Update PowerShell Help ====================

        # Update the outer progress bar while updating help
        $PercentCompleteOuter = 70
        $ProgressParamOuter = @{
            Id               = 0
            Activity         = 'Update Everything'
            CurrentOperation = 'Updating PowerShell Help'
            Status           = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete  = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter

        if (-not $SkipHelp) {
            Write-Host '[3] Updating PowerShell Help'
            # Fixes error with culture ID 127 (Invariant Country), which is not associated with any language
            if ((Get-Culture).LCID -eq 127) {
                Update-Help -UICulture en-US -ErrorAction SilentlyContinue
            } else {
                Update-Help -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host '[3] Skipping PowerShell Help'
        }
        #endregion UpdatePowerShell

        #region UpdateWinget
        # >>> Create a section to check OS and client/server OS at the top of the script <<< #
        if ($IsWindows -or ($PSVersionTable.PSVersion -le [version]'5.1')) {

            if ((Get-CimInstance -ClassName CIM_OperatingSystem).Caption -match 'Server') {
                # If on Windows Server, prompt to continue before automatically updating packages.
                Write-Warning -Message 'This is a server and updates could affect production systems. Do you want to continue with updating packages?'

                $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Description.'
                $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Description.'
                $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)

                $Title = 'Windows Server OS Found'
                $Message = "Do you want to run 'winget update' on your server?"
                $Result = $Host.UI.PromptForChoice($Title, $Message, $Options, 1)
                switch ($Result) {
                    0 {
                        continue
                    }
                    1 {
                        $SkipWinGet = $true
                    }
                }
            }

            if (-not $SkipWinGet) {
                # Update all winget packages
                Write-Host '[4] Updating Winget Packages'
                # Update the outer progress bar for winget section
                $PercentCompleteOuter = 80
                $ProgressParamOuter = @{
                    Id               = 0
                    Activity         = 'Update Everything'
                    CurrentOperation = 'Updating Winget Packages'
                    Status           = "Progress: $PercentCompleteOuter`% Complete"
                    PercentComplete  = $PercentCompleteOuter
                }
                Write-Progress @ProgressParamOuter
                if (Get-Command winget -ErrorAction SilentlyContinue) {
                    winget upgrade --silent --scope user --accept-package-agreements --accept-source-agreements --all
                } else {
                    Write-Host '[4] WinGet was not found. Skipping WinGet update.'
                }
            } else {
                Write-Host '[3] Skipping WinGet'
                continue
            }
        } else {
            Write-Verbose '[4] Not Windows. Skipping WinGet.'
        }
        #endregion UpdateWinget

        #region UpdateLinuxPackages
        # Early testing. No progress bar yet. Need to check for admin, different distros, and different package managers.
        if ($IsLinux) {
            if (Get-Command apt -ErrorAction SilentlyContinue) {
                Write-Host '[5] Updating apt packages.'
                sudo apt update
                sudo apt upgrade
            }
            if (Get-Command dnf -ErrorAction SilentlyContinue) {
                Write-Host '[5] Updating dnf packages.'
                sudo update
            }
        } else {
            Write-Verbose '[5] Not Linux. Skipping section.'
        }
        #endregion UpdateLinuxPackages

        #region UpdateMacOS
        # Early testing. No progress bar yet. Need to check for admin and different package managers.
        if ($IsMacOS) {
            softwareupdate -l
            if (Get-Command brew -ErrorAction SilentlyContinue) {
                Write-Host '[6] Updating brew packages.'
                brew update
                brew upgrade
            }
        } else {
            Write-Verbose '[6] Not macOS. Skipping section.'
        }
        #endregion UpdateMacOS

        #region UpdateChocolatey
        # Upgrade Chocolatey packages. Need to check for admin to avoid errors/warnings.
        if ((Get-Command choco -ErrorAction SilentlyContinue) -and $IncludeChocolatey) {
            # Update the outer progress bar
            $PercentCompleteOuter = 90
            $ProgressParamOuter = @{
                Id               = 0
                Activity         = 'Update Everything'
                CurrentOperation = 'Updating Chocolatey Packages'
                Status           = "Progress: $PercentCompleteOuter`% Complete"
                PercentComplete  = $PercentCompleteOuter
            }
            Write-Progress @ProgressParamOuter
            Write-Host '[7] Updating Chocolatey Packages'
            # Add a function/parameter to run these two feature configuration options, which requires admin to set.
            if (Test-IsElevated) {
                # Oops, this depends on PSPreworkout being installed or that function otherwise being available.
                choco feature enable -n=allowGlobalConfirmation
                choco feature disable --name=showNonElevatedWarnings
            } else {
                Write-Verbose "Run once as an administrator to disable Chocolately's showNonElevatedWarnings." -Verbose
            }
            choco upgrade chocolatey -y --limit-output --accept-license --no-color
            choco upgrade all -y --limit-output --accept-license --no-color
            # Padding to reset host before updating the progress bar.
            Write-Host ' '
        } else {
            Write-Host '[7] Skipping Chocolatey'
        }
        #endregion UpdateChocolatey

    } # end process block

    end {
        Write-Host 'Done.'
        # Update the outer progress bar
        $PercentCompleteOuter = 100
        $ProgressParamOuter = @{
            Id               = 0
            Activity         = 'Update Everything'
            CurrentOperation = 'Finished'
            Status           = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete  = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter
        # Complete the outer progress bar
        Write-Progress -Id 0 -Activity 'Update Everything' -Completed
    }

}




