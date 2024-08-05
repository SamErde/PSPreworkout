<#
    .DESCRIPTION
        A quick proof of concept for pulling a list of Microsoft PowerShell modules from the msshells.net project.

    .NOTES
        Credit and thanks to Andrés Gorzelany for permission to depend on the MSSHELLS.NET project for its data!

        See https://github.com/get-itips/msshells, https://twitter.com/AndresGorzelany
#>

function Get-MsShellsModules {
    $MsShellsRepoUri = 'https://api.github.com/repos/get-itips/msshells/contents/_ps_modules'
    $Content = Invoke-RestMethod -Uri $MsShellsRepoUri

    foreach ($item in $Content) {
        $DownloadPath = "msshells-content/$($item.name)"
        Invoke-RestMethod -Uri $item.download_url -OutFile $DownloadPath
    }
}

function Read-ModuleInfo {
    Install-Module powershell-yaml
    Import-Module powershell-yaml

    $PsModuleFiles = Get-ChildItem -Path 'msshells-content/*.md'
    foreach ($item in $PsModuleFiles) {

        $Module = ConvertFrom-Yaml -Yaml ([System.IO.File]::ReadAllText("$item"))
        Find-Module -Name $Module.name
    }
}

<#
    Compare with sample from checker.ps1
    # Convert files from YAML
    $moduleDataObj = Get-ChildItem -Path $dataFolderPath | ForEach-Object {
        @{
        FileName = $PSItem.Name
        Content = ConvertFrom-Yaml -Yaml (
            Get-Content -Path $PSItem -Raw
            ).replace("---`n", "").trim()
        }
    }
#>

function Get-EnvironmentVariable {
    <#
        .SYNOPSIS
            Retrieves the value of an environment variable.

        .DESCRIPTION
            The Get-EnvironmentVariable function retrieves the value of the specified environment variable
            or displays all environment variables.

        .PARAMETER Name
            The name of the environment variable to retrieve.

        .EXAMPLE
            Get-EnvironmentVariable -Name "PATH"
            Retrieves the value of the "PATH" environment variable.

        .OUTPUTS
            System.String
            The value of the environment variable.

        .NOTES
            Variable names are case-sensitive on Linux and macOS, but not on Windows.

            Why is 'Target' used by .NET instead of the familiar 'Scope' parameter name? @IISResetMe (Mathias R. Jessen) explains:
            "Scope" would imply some sort of integrated hierarchy of env variables - that's not really the case.
            Target=Process translates to kernel32!GetEnvironmentVariable (which then in turn reads the PEB from
            the calling process), whereas Target={User,Machine} causes a registry lookup against environment
            data in either HKCU or HKLM.

            The relevant sources for the User and Machine targets are in the registry at: 
            - HKEY_CURRENT_USER\Environment
            - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
        .LINK
            https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables
    #>
    [Alias("gev")]
    [Outputs([System.String])]
    [CmdletBinding()]
    param (
        # The name of the environment variable to retrieve. If not specified, all environment variables are returned.
        [Parameter()]
        [string]$Variable,

        # The target of the environment variable to retrieve. Defaults to Machine. (Process, User, or Machine)
        [Parameter()]
        [System.EnvironmentVariableTarget]
        $Target = [System.EnvironmentVariableTarget]::Machine,

        # Switch to show environment variables in all target scopes.
        [Parameter()]
        [switch]
        $All
    )
    
    begin {
    }
    
    process {
        if ( $PSBoundParameters.Contains($Variable) ) {
            [Environment]::GetEnvironmentVariable($Variable, $Target)
        }
        elseif (-not $PSBoundParameters.Contains($All) ) {
            [Environment]::GetEnvironmentVariables()
        }

        if ($All) {
            Write-Output "Process Environment Variables:"
            [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Process)
            Write-Output "User Environment Variables:"
            [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User)
            Write-Output "Machine Environment Variables:"
            [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine)
        }
    }
    
    end {
    }
}

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
        [ValidateSet("winget", "msstore")]
        [string]$WingetSource = "winget",
        [Parameter()]
        [ValidateSet("chocolatey", "direct", "scoop", "winget")]
        [string]$Method = "direct",

        [Parameter(ParameterSetName = 'Font')]
        [switch]$InstallNerdFont,
        [Parameter (ParameterSetName = 'Font')]
        [ValidateSet("Default", "Select One", "Meslo")]
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

function Install-PowerShellISE {
    <#
    .SYNOPSIS
        Install the Windows PowerShell ISE if you removed it after installing VS Code.

    .DESCRIPTION
        This script installs the Windows PowerShell ISE if it is not already. It includes a step that resets the Windows
        Automatic Update server source in the registry temporary, which may resolve errors that some people experience
        while trying to add Windows Capabilities. This was created because Out-GridView in Windows PowerShell 5.1 does not
        work without the ISE installed. However, Out-GridView was rewritten and included in PowerShell 7 for Windows.

    .NOTES
        Author: Sam Erde

        To Do:
            - Check for Windows client vs Windows Server OS
            - Add parameter to make the Windows Update registry change optional
    #>

    #Requires -RunAsAdministrator

    if ((Get-WindowsCapability -Name 'Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0' -Online).State -eq "Installed") {
        Write-Output "The Windows PowerShell ISE is already installed."
    }
    else {
        # Resetting the Windows Update source sometimes resolves errors when trying to add Windows capabilities
        $CurrentWUServer = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | Select-Object -ExpandProperty UseWUServer
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
        Restart-Service wuauserv

        try {
            Get-WindowsCapability -Name Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0 -Online | Add-WindowsCapability -Online -Verbose
        }
        catch {
            Write-Error "There was a problem adding the Windows PowerShell ISE: $error"
        }

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $CurrentWUServer
        Restart-Service wuauserv
    }
}

function New-ProfileWorkspace {
    <#
    .SYNOPSIS
        Setup a folder and VS Code Workspace for maintaining your PowerShell profiles, VS Code settings, and Windows Terminal settings.

    .DESCRIPTION
        I wanted an easy way to maintain all of my CurrentUser PowerShell profiles and settings for Visual Studio Code
        and Windows Terminal. This script creates a folder that contains:

            - Junction points to the locations of your CurrentUser PowerShell and Windows PowerShell folders
            - Junction points to the locations of your settings for VS Code and Windows Terminal
            - A Visual Studio Code workspace file that opens this new folder
            - EditorConfig and Visual Studio Code settings files for consistent editing
            - A .gitignore file in case you want to use this as a git repository (test?)

    .PARAMETER WorkspacePath
        The location to create your profile workspace in. The default value is a "Repositories/ProfileWorkspace" folder in
        the current user's home folder. Example: "C:/Users/sam.erde/Repositories/ProfileWorkspace"

    .PARAMETER PowerShellPath
        The location of the current user's PowerShell folder that should contain their profile.

    .PARAMETER WindowsPowerShellPath
        The location of the current user's WindowsPowerShell folder that should contain their profile.

    .PARAMETER Launch
        A switch that, if used, will launch the VS Code workspace upon completion of this script.

    .NOTES
        Author: Sam Erde, https://www.twitter.com/SamErde
        Created: 2023/11/28

        Profile Locations on Windows:
            ~/Documents/PowerShell/profile.ps1
            ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1

            ~/Documents/WindowsPowerShell/profile.ps1
            ~/Documents/WindowsPowerShell/Microsoft.VSCode_profile.ps1
            ~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1

        Settings Locations on Windows:
            ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
            ~/AppData/Roaming/Code/User/settings.json

        To Do:
            - [ ] Check for existence of junction points and target locations
            - [ ] Wrap New-Item in try/catch blocks
            - [ ] Take initial creation location for this setup as a parameter with a clear default value
            - [ ] Create function for a dot-sourced base profile that is stored in a git repo or synced user profile location
            - [ ] Add support for Linux and macOS?

    .LINK
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $WorkspacePath = "~/Repositories/ProfileWorkspace",
        [Parameter()]
        [string]
        $PowerShellPath = ( Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) '/PowerShell' ),
        [Parameter()]
        [string]
        $WindowsPowerShellPath = ( Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) '/WindowsPowerShell' ),
        [Parameter()]
        [switch]
        $Launch
    )

    $CurrentInformationPreference = $InformationPreference
    $InformationPreference = 'Continue'

    # Check for the workspace path before creating it
    if (-not (Test-Path $WorkspacePath) ) {
        Write-Information -MessageData "Creating directory `"$WorkspacePath`"." -Tags "WorkspacePath"
        New-Item -ItemType Directory -Path $WorkspacePath | Out-Null
    }
    else {
        Write-Information -MessageData "Found `"$WorkspacePath`". Continuing..." -Tags "WorkspacePath"
    }
    $WorkspacePath = (Get-Item $WorkspacePath).FullName
    Set-Location -Path $WorkspacePath

    $JunctionPoints = @{
        "PowerShell"        = ( Join-Path -Path $WorkspacePath -ChildPath 'PowerShell' )
        "WindowsPowerShell" = ( Join-Path -Path $WorkspacePath -ChildPath 'WindowsPowerShell' )
        "Code"              = ( Join-Path -Path $env:AppData -ChildPath '/Code/User' )
        "WindowsTerminal"   = ( Join-Path -Path $env:LocalAppData -ChildPath '/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState' )
    }

    foreach ( $item in $JunctionPoints.GetEnumerator() ) {
        Write-Information -MessageData "Looking for $($item.Name) at $($item.Value)" -Tags "JunctionPoints"
        if (-not (Test-Path -Path $($item.Value) -Verbose) ) {
            New-Item -Type Junction -Path $($item.Value) -Name $($item.Name) -Value $PowerShellPath | Out-Null
            Write-Information -MessageData "Created $($item.Name) junction point in $($item.Value). No action required.`n"  -Tags "JunctionPoints"
        }
        else {
            Write-Information -MessageData "Found a $($item.Name) junction point at $($item.Value). No action required.`n"  -Tags "JunctionPoints"
        }
    }

    $workspaceContent = @{
        folders = @(
            @{
                path = $WorkspacePath
            }
        )
    }
    $WorkspaceContent | ConvertTo-Json | Set-Content (Join-Path $WorkspacePath 'ProfileWorkspace.code-workspace') -Encoding utf8 -Force

    if ($Launch) {
        code Join-Path -Path $WorkspacePath -ChildPath '/ProfileWorkspace.code-workspace'
    }

    $InformationPreference = $CurrentInformationPreference
}

function Set-EnvironmentVariable {
    [Alias("sev")]
    [CmdletBinding()]
    param (
        # The name of the environment variable to set.
        [Parameter(Mandatory)]
        [string]$Name,

        # The value of environment variable to set.
        [Parameter(Mandatory)]
        [string]
        $Value,

        # The target of the environment variable to set.
        [Parameter()]
        [System.EnvironmentVariableTarget]
        $Target
    )
    
    begin {
    }
    
    process {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }
    
    end {
    }
}

<#PSScriptInfo
.DESCRIPTION A script to automatically update all PowerShell modules, PowerShell Help, and packages (apt, brew, chocolately, winget).
.VERSION 0.3.3
.GUID 3a1a1ec9-0ef6-4f84-963d-be1505dab6a8
.AUTHOR Sam Erde
.COPYRIGHT (c) Sam Erde
.TAGS Update PowerShell Windows macOS Linux Ubuntu
.LICENSEURI https://github.com/SamErde/PowerShell-Pre-Workout/blob/main/LICENSE
.PROJECTURI https://github.com/SamErde/PowerShell-Pre-Workout/
.ICONURI
#>

function Update-AllTheThings {
    <#
    .SYNOPSIS
    Update-AllTheThings: Update all the things!

    .DESCRIPTION
    A script to automatically update all PowerShell modules, PowerShell Help, and packages (apt, brew, chocolately, winget).

    .EXAMPLE
    PS> Update-AllTheThings

    Updates all of the things it can!

    .INPUTS
    None. You can't pipe objects to Update-Everything.

    .OUTPUTS
    None. Update-Everything does not return any objects.

    .LINK
    Twitter https://twitter.com/SamErde

    .NOTES
    Author: Sam Erde
    Version: 0.3.3
    Modified: 2024/08/05
    #>

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', 'Update-AllTheThings', Justification = 'Riding the "{___} all the things train!"')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive Use')]
    [Alias("UATT")]
    param ()

    # Spacing to get host output from script, winget, and choco all below the progress bar.
    Write-Host @'
  __  __        __     __         ___   ____
 / / / /__  ___/ /__ _/ /____    / _ | / / /
/ /_/ / _ \/ _  / _ `/ __/ -_)  / __ |/ / /
\____/ .__/\_,_/\_,_/\__/\__/  /_/ |_/_/_/
 ___/_/__         ________   _
/_  __/ /  ___   /_  __/ /  (_)__  ___ ____
 / / / _ \/ -_)   / / / _ \/ / _ \/ _ `(_-<
/_/ /_//_/\__/   /_/ /_//_/_/_//_/\_, /___/
                                 /___/

'@
    # Get all installed PowerShell modules
    Write-Host "[1] Getting Installed PowerShell Modules"
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
    $Modules = (Get-InstalledModule)
    $ModuleCount = $Modules.Count


    # Update all PowerShell modules
    Write-Host "[2] Updating $ModuleCount PowerShell Modules"
    # Estimate 10% progress so far and 70% at the next step
    $PercentCompleteOuter_Modules = 10
    [int]$Module_i = 0

    foreach ($module in $Modules) {
        # Update the module loop counter and percent complete for both progress bars
        ++$Module_i
        [double]$PercentCompleteInner = [math]::ceiling( (($Module_i / $ModuleCount) * 100) )
        [double]$PercentCompleteOuter = [math]::ceiling( $PercentCompleteOuter_Modules + (60 * ($PercentCompleteInner / 100)) )

        # Update the outer progress bar
        $ProgressParamOuter = @{
            Id              = 0
            Activity        = 'Update Everything'
            Status          = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter

        # Update the child progress bar
        $ProgressParam1 = @{
            Id               = 1
            ParentId         = 0
            Activity         = 'Updating PowerShell Modules'
            CurrentOperation = "$($module.Name)"
            Status           = "Progress: $PercentCompleteInner`% Complete"
            PercentComplete  = $PercentCompleteInner
        }
        Write-Progress @ProgressParam1

        # Update the current module
        try {
            Update-Module $ -ErrorAction SilentlyContinue
        }
        catch [Microsoft.PowerShell.Commands.WriteErrorException] {
            Write-Verbose $_
        }
    }
    # Complete the child progress bar
    Write-Progress -Id 1 -Activity 'Updating PowerShell Modules' -Completed


    # Update PowerShell Help
    Write-Host "[3] Updating PowerShell Help"
    # Update the outer progress bar
    $PercentCompleteOuter = 70
    $ProgressParamOuter = @{
        Id               = 0
        Activity         = 'Update Everything'
        CurrentOperation = 'Updating PowerShell Help'
        Status           = "Progress: $PercentCompleteOuter`% Complete"
        PercentComplete  = $PercentCompleteOuter
    }
    Write-Progress @ProgressParamOuter
    # Fixes error with culture ID 127 (Invariant Country), which is not associated with any language
    if ((Get-Culture).LCID -eq 127) {
        Update-Help -UICulture en-US -ErrorAction SilentlyContinue
    }
    else {
        Update-Help -ErrorAction SilentlyContinue
    }

    if ($IsWindows -or ($PSVersionTable.PSVersion -like "5.1.*")) {
        # Update all winget packages
        Write-Host "[4] Updating Winget Packages"
        # Update the outer progress bar
        $PercentCompleteOuter = 80
        $ProgressParamOuter = @{
            Id               = 0
            Activity         = 'Update Everything'
            CurrentOperation = 'Updating Winget Packages'
            Status           = "Progress: $PercentCompleteOuter`% Complete"
            PercentComplete  = $PercentCompleteOuter
        }
        Write-Progress @ProgressParamOuter
        <# Check for Windows and/or winget.exe
        if () { }
        #>
        winget upgrade --silent --scope user --accept-package-agreements --accept-source-agreements --all
    }

    # Early testing. No progress bar yet. Need to check for admin, different distros, and different package managers.
    if ($IsLinux) {
        if (Get-Command apt -ErrorAction SilentlyContinue) {
            Write-Host '[6] Updating apt packages.'
            sudo apt update
            sudo apt upgrade
        }
    }

    # Early testing. No progress bar yet. Need to check for admin and different package managers.
    if ($IsMacOS) {
        softwareupdate -l
        if (Get-Command brew -ErrorAction SilentlyContinue) {
            Write-Host '[7] Updating brew packages.'
            brew update
            brew upgrade
        }
    }

    # Upgrade Chocolatey packages. Need to check for admin.
    if (Get-Command choco -ErrorAction SilentlyContinue) {
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
        Write-Host "[5] Updating Chocolatey Packages"
        choco upgrade chocolatey --limitoutput --yes
        choco upgrade all --limitoutput --yes
    }
    else {
        Write-Host "[5] Chocolatey is not installed. Skipping choco update."
    }


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



# Export functions and aliases as required
Export-ModuleMember -Function @('Get-EnvironmentVariable', 'Get-MsShellsModules', 'Install-OhMyPosh', 'Install-PowerShellISE', 'New-ProfileWorkspace', 'Read-ModuleInfo', 'Set-EnvironmentVariable', 'Update-AllTheThings') -Alias @('gev', 'sev', 'UATT') -Cmdlet "*"