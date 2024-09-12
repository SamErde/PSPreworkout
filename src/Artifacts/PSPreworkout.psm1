# This is a locally sourced Imports file for local development.
# It can be imported by the psm1 in local development to add script level variables.
# It will merged in the build process. This is for local development only.

# region Script Variables
# $script:resourcePath = "$PSScriptRoot\Resources"
Export-ModuleMember -Alias *


function Edit-WingetSettingsFile {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding()]
    param (
    )

    if (Test-Path -PathType Container -Path "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState") {
        if (Get-Command code -ErrorAction SilentlyContinue) {
            code "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        } else {
            notepad "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        }
    } else {
        Write-Information -MessageData 'WinGet is not installed.' -InformationAction Continue
    }
}



function Get-EnvironmentVariable {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [Alias('gev')]
    [CmdletBinding()]
    [OutputType([string])]
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
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'But this is better.')]
    # [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'There is a lot of them.')]
    [Alias('Show-Assemblies')]
    param (
        # Show a grid view of the loaded assemblies
        [Parameter()]
        [switch]
        $GridView
    )

    $LoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $_.Location } | Sort-Object -Property FullName | Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted

    if ($PSBoundParameters.ContainsKey('GridView')) {

        if ((Get-Command -Name Out-ConsoleGridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Core')) {

            $LoadedAssemblies | Out-ConsoleGridView -OutputMode Multiple

        } elseif ((Get-Command -Name Out-GridView -ErrorAction SilentlyContinue) -and ($PSVersionTable.PSEdition -eq 'Desktop')) {

            $LoadedAssemblies | Out-GridView -OutputMode Multiple

        } else {
            Write-Output 'The Out-GridView and Out-ConsoleGridView cmdlets were not found. Please install the Microsoft.PowerShell.ConsoleGuiTools module or re-install the PowerShell ISE if using Windows PowerShell 5.1.'
            $LoadedAssemblies | Format-Table -AutoSize
        }
    }
    $LoadedAssemblies
}



function Get-TypeAccelerator {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Fighting with VS Code autoformatting.')]
    #[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Get-TypeAccelerators', Justification = 'The type accelerators are plural.')]
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

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentIndentation', '', Justification = 'Agument completers are weird.')]
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
        # Suppress PSScriptAnalyzer Errors
        $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter | Out-Null
    }

    process {
        # Configure git user settings
        if ($PSBoundParameters.ContainsKey('Name')) { git config --global user.name $Name }
        if ($PSBoundParameters.ContainsKey('Email')) { git config --global user.email $Email }

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



function Install-OhMyPosh {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding()]
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

    [CmdletBinding()]
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

    [CmdletBinding()]
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
            Add-AppxPackage $DesktopAppInstallerPackage
            Add-AppxPackage $VCLibsPackage
            Add-AppxPackage $XamlPackage
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
    [CmdletBinding()]
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



function Set-ConsoleFont {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding()]
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
    [CmdletBinding()]
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



function Test-IsElevated {
    <#
.EXTERNALHELP PSPreworkout-help.xml
#>
    [CmdletBinding()]
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
                                 /___/ v0.5.7

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




