---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
schema: 2.0.0
---

# New-ProfileWorkspace

## SYNOPSIS
Setup a folder and VS Code Workspace for maintaining your PowerShell profiles, VS Code settings, and Windows Terminal settings.

## SYNTAX

```
New-ProfileWorkspace [[-WorkspacePath] <String>] [[-PowerShellPath] <String>]
 [[-WindowsPowerShellPath] <String>] [-Launch] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
I wanted an easy way to maintain all of my CurrentUser PowerShell profiles and settings for Visual Studio Code
and Windows Terminal.

## EXAMPLES

### EXAMPLE 1
```
New-ProfileWorkspace
```

## PARAMETERS

### -WorkspacePath
The location to create your profile workspace in.
The default value is a "Repositories/ProfileWorkspace" folder in
the current user's home folder.
Example: "C:/Users/sam.erde/Repositories/ProfileWorkspace"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: ~/Repositories/ProfileWorkspace
Accept pipeline input: False
Accept wildcard characters: False
```

### -PowerShellPath
The location of the current user's PowerShell folder that should contain their profile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ( Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) '/PowerShell' )
Accept pipeline input: False
Accept wildcard characters: False
```

### -WindowsPowerShellPath
The location of the current user's WindowsPowerShell folder that should contain their profile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: ( Join-Path ([System.Environment]::GetFolderPath('MyDocuments')) '/WindowsPowerShell' )
Accept pipeline input: False
Accept wildcard characters: False
```

### -Launch
A switch that, if used, will launch the VS Code workspace upon completion of this script.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Sam Erde, https://www.twitter.com/SamErde
Created: 2023/11/28

This script creates a folder that contains:

    - Junction points to the locations of your CurrentUser PowerShell and Windows PowerShell folders
    - Junction points to the locations of your settings for VS Code and Windows Terminal
    - A Visual Studio Code workspace file that opens this new folder
    - EditorConfig and Visual Studio Code settings files for consistent editing
    - A .gitignore file in case you want to use this as a git repository (test?)

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
    - \[ \] Check for existence of junction points and target locations
    - \[ \] Wrap New-Item in try/catch blocks
    - \[ \] Take initial creation location for this setup as a parameter with a clear default value
    - \[ \] Create function for a dot-sourced base profile that is stored in a git repo or synced user profile location
    - \[ \] Add support for Linux and macOS?

## RELATED LINKS

[https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)
