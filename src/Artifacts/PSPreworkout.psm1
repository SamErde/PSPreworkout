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

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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
        #Remove-Item -Path $TempScriptFile -Confirm:$false
    } # end end block

} # end function Edit-PSreadLineHistoryFile



function Edit-WingetSettingsFile {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    param (
        # Specify the path to the editor that you would like to use.
        [Parameter()]
        [ValidateScript({
                if ( -not (Test-Path -Path $_ ) ) {
                    throw 'The file does not exist.'
                }
                return $true
            })]
        [System.IO.FileInfo]
        $EditorPath
    )

    begin {
        $WinGetSettingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        if (-not (Test-Path -PathType Leaf -Path $WinGetSettingsFile)) {
            # Exit the function if the WinGet settings file does not exist.
            Write-Information -MessageData 'WinGet is not installed.' -InformationAction Continue
            return
        }
    } # end begin block

    process {
        if ($PSBoundParameters.ContainsKey($EditorPath)) {
            Start-Process $EditorPath $WinGetSettingsFile
        } elseif ( (Get-Command code -ErrorAction SilentlyContinue) ) {
            code $WinGetSettingsFile
        } else {
            Start-Process notepad $WinGetSettingsFile
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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [OutputType('System.String')]
    param (
        # The name of the environment variable to retrieve. If not specified, all environment variables are returned.
        [Parameter(Position = 0)]
        [string]$Name,

        # The target of the environment variable to retrieve. Defaults to User. (Process, User, or Machine)
        [Parameter(Position = 1)]
        [System.EnvironmentVariableTarget]
        $Target = [System.EnvironmentVariableTarget]::User,

        # Switch to show environment variables in all target scopes.
        [Parameter()]
        [switch]
        $All
    )

    # If a variable name was specified, get that environment variable from the default target or specified target.
    if ( $PSBoundParameters.Keys.Contains('Name') ) {
        [Environment]::GetEnvironmentVariable($Name, $Target)
    } elseif (-not $PSBoundParameters.Keys.Contains('All') ) {
        [Environment]::GetEnvironmentVariables()
    }

    # If only the target is specified, get all environment variables from that target.
    if ( $PSBoundParameters.Keys.Contains('Target') -and -not $PSBoundParameters.ContainsKey('Name') ) {
        [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$Target)
    }

    # Get all environment variables from all targets.
    # To Do: Get the specified variable name from all targets if a name and -All are specified.
    if ($All) {
        Write-Output 'Process Environment Variables:'
        [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Process)
        Write-Output 'User Environment Variables:'
        [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User)
        Write-Output 'Machine Environment Variables:'
        [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine)
    }
}



function Get-LoadedAssembly {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [OutputType('System.Array')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    [Alias('Get-Assembly')]
    param ()

    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName
}



function Get-PowerShellPortable {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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
    #$ApiUrl = 'https://api.github.com/repos/PowerShell/PowerShell/releases/tags/v7.4.5'
    #$Response = Invoke-RestMethod -Uri $ApiUrl -Headers @{ 'User-Agent' = 'PowerShellScript' }
    #$Assets = $Response.assets
    #$DownloadLinks = $Assets | Where-Object { $_.browser_download_url -match '\.zip$|\.tar\.gz$' } | Select-Object -ExpandProperty browser_download_url
    $DownloadLinks = (Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest').assets.browser_download_url

    # Determine the platform and architecture
    $Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    # OSArchitecture isn't present in older versions of .NET Framework, so use the environment variable as a fallback for Windows.
    if (-not $Architecture) { $Architecture = $([System.Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE')).Replace('AMD64', 'X64') }

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
                # Expand the zip file into a folder that matches the zip filename without the zip extenstion
                if (Test-Path -PathType Container -Path (Join-Path -Path $Path -ChildPath $PwshDirectory)) {
                    Expand-Archive -Path $OutFilePath -DestinationPath (Join-Path -Path $Path -ChildPath $PwshDirectory) -Force
                    Write-Information -MessageData "PowerShell has been extracted to $PwshPath" -InformationAction Continue
                    Write-Information -MessageData "Run '$PwshPath\pwsh.exe' to launch the latest version of PowerShell without installing it!" -InformationAction Continue
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



function Get-TypeAccelerator {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [OutputType('System.Array')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Fighting with VS Code autoformatting.')]
    param (

        # Parameter help description
        [Parameter(Position = 0, HelpMessage = 'The name of the type accelerator, such as "ADSI."')]
        [SupportsWildcards()]
        [string]
        $Name = '*',

        # Show a grid view of the loaded assemblies
        [Parameter()]
        [switch]
        $GridView
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

    if ($PSBoundParameters.ContainsKey('GridView')) {

        if ((Get-Command -Name Out-ConsoleGridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Core')) {

            $TypeAccelerators | Out-ConsoleGridView -OutputMode Multiple

        } elseif ((Get-Command -Name Out-GridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Desktop')) {

            $TypeAccelerators | Out-GridView -OutputMode Multiple

        } else {
            Write-Output 'The Out-GridView and Out-ConsoleGridView cmdlets were not found. Please install the Microsoft.PowerShell.ConsoleGuiTools module or re-install the PowerShell ISE if using Windows PowerShell 5.1.'
            $TypeAccelerators | Format-Table -AutoSize
        }
    }

    $TypeAccelerators
}



function Initialize-PSEnvironmentConfiguration {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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

        # PowerShell modules to install
        [Parameter()]
        [string[]]
        $Modules = @('CompletionPredictor', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.PSResourceGet', 'posh-git', 'PowerShellForGitHub', 'Terminal-Icons'),

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

        #region Default Settings, All Versions
        $PSDefaultParameterValues = @{
            'ConvertTo-Csv:NoTypeInformation' = $True # Does not exist in pwsh
            'ConvertTo-Xml:NoTypeInformation' = $True
            'Export-Csv:NoTypeInformation'    = $True # Does not exist in pwsh
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
                    Install-Module -Name $module -Scope CurrentUser -AcceptLicense
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



function Install-CommandNotFoundUtility {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]

    param (

    )

    begin {

    } # end begin block

    process {
        # Can be installed independently of PowerToys now
        # Start-Process 'winget' -ArgumentList 'install --id Microsoft.PowerToys --source winget' -Wait -NoNewWindow

        # To Do: Check for installed module and module version
        Install-Module -Name Microsoft.WinGet.CommandNotFound -Scope CurrentUser -Force
        Import-Module -Name Microsoft.WinGet.CommandNotFound

        # To Do: Check if already enabled:
        Enable-ExperimentalFeature -Name 'PSFeedbackProvider'
        Enable-ExperimentalFeature -Name 'PSCommandNotFoundSuggestion'

        # Add to profile:
        # <https://github.com/microsoft/PowerToys/blob/main/src/settings-ui/Settings.UI/Assets/Settings/Scripts/EnableModule.ps1>

    } # end process block

    end {

    } # end end block

} # end function Install-CommandNotFoundUtility



function Install-OhMyPosh {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    param ()

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
}



function Install-WinGet {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
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

    [CmdletBinding()]
    __ALIAS__
    param (

    )

    begin {

    } # end begin block

    process {

    } # end process block

    end {

    } # end end block

} # end function New-Function
'@

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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    param (
        # Object to convert to JSON and save it to a file.
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        # Check for empty objects here or in the function body?
        # [ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_) -and -not [string]::IsNullOrEmpty($_)) { $true } })]
        [Object]
        $Object,

        # Full path and filename to save the JSON to.
        [Parameter(Position = 1)]
        [ValidatePattern('\.json$')]
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
        $Object | ConvertTo-Json | Out-File -FilePath $OutFile -Force
    } # end process block

    end {
        Remove-Variable Object, FilePath, Path, OutFile -ErrorAction SilentlyContinue
    } # end end block
}



function Set-ConsoleFont {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Agument completers are weird.')]
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



function Set-EnvironmentVariable {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [Alias('sev')]
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    # [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'There is a lot of them.')]
    [Alias('Show-LoadedAssemblies')]
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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
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

    [CmdletBinding(SupportsShouldProcess)]
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
                                 /___/ v0.5.8

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
            if ($module.Version -match 'alpha|beta|prelease|preview') {
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
        if ($IsWindows -or ($PSVersionTable.PSVersion -ge [version]'5.1')) {

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
                Write-Verbose "Run once as an administrator to disable Chocoately's showNonElevatedWarnings." -Verbose
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




