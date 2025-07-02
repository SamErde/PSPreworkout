---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Initialize-PSEnvironmentConfiguration

## SYNOPSIS
Initialize configuration your PowerShell environment and git.

## SYNTAX

```
Initialize-PSEnvironmentConfiguration [-Name] <String> [-Email] <String> [[-Font] <String>]
 [[-Packages] <String[]>] [-SkipPackages] [[-Modules] <String[]>] [-SkipModules]
 [<CommonParameters>]
```

## DESCRIPTION
Install supporting packages, configure git, and set your console font with this function.

## EXAMPLES

### EXAMPLE 1
```
Initialize the PowerShell working environment with a custom font, and set my name and email address for Git commits.
```

Initialize-PSEnvironmentConfiguration -Name 'Sam Erde' -Email 'sam@example.local' -ConsoleFont 'FiraCode Nerd Font'

## PARAMETERS

### -Name
Your name to be used for git commits.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
Your email to be used for git commits.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Font
The font to use for your consoles (PowerShell, Windows PowerShell, git bash, etc.)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Packages
Packages to install with winget.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: @('Microsoft.WindowsTerminal', 'git.git', 'JanDeDobbeleer.OhMyPosh')
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipPackages
Option to skip installation of default packages.

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

### -Modules
PowerShell modules to install.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: @('CompletionPredictor', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.PSResourceGet', 'posh-git', 'PowerShellForGitHub', 'Terminal-Icons', 'PSReadLine', 'PowerShellGet')
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipModules
Option to skip installation of default modules.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Sam Erde
Version: 0.0.3
Modified: 2024/11/08

To Do
    Add status/verbose output of changes being made
    Create basic starter profile if none exist
    Create dot-sourced profile
    Create interactive picker for packages and modules (separate functions)
    Bootstrap Out-GridView or Out-ConsoleGridView for the interactive picker
    Do not install already installed packages
    Do not install ConsoleGuiTools in Windows PowerShell

## RELATED LINKS
