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
            $PowerShellPath = ( [System.Environment]::GetFolderPath("MyDocuments") + "/WindowsPowerShell" ),
        [Parameter()]
            [string]
            $WindowsPowerShellPath = ( [System.Environment]::GetFolderPath("MyDocuments") + "/WindowsPowerShell" ),
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
        "PowerShell" = "$WorkspacePath/PowerShell"
        "WindowsPowerShell" = "$WorkspacePath/WindowsPowerShell"
        "Code" = "$env:AppData/Code/User"
        "WindowsTerminal" = "$env:LocalAppData/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
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
        code "$WorkspacePath/ProfileWorkspace.code-workspace"
    }

    $InformationPreference = $CurrentInformationPreference
}
