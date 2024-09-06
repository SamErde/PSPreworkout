---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables
schema: 2.0.0
---

# Initialize-Configuration

## SYNOPSIS
Initialize configuration your PowerShell environment and git.

## SYNTAX

```
Initialize-Configuration [[-Name] <String>] [[-Email] <String>] [[-CentralProfile] <String>]
 [[-ConsoleFont] <String>] [[-Packages] <String[]>] [-SkipPackages] [-PickPackages] [[-Modules] <String[]>]
 [-SkipModules] [-PickModules] [<CommonParameters>]
```

## DESCRIPTION
Install supporting packages, configure git, and set your console font with this function.

## EXAMPLES

### EXAMPLE 1
```
Initialize-Configuration
```

Init-Configuration -Name 'Sam Erde' -Email 'sam@example.local' -ConsoleFont 'FiraCode Nerd Font'

## PARAMETERS

### -Name
Your name to be used for git commits.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CentralProfile
The file path to your central PowerShell profile.

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

### -ConsoleFont
The font to use for your consoles (PowerShell, Windows PowerShell, git bash, etc.)

```yaml
Type: String
Parameter Sets: (All)
Aliases: Font

Required: False
Position: 4
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
Position: 5
Default value: @('Microsoft.PowerShell', 'Microsoft.WindowsTerminal', 'git.git', 'JanDeDobbeleer.OhMyPosh')
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

### -PickPackages
Choose which packages you want to install.

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
Position: 6
Default value: @('CompletionPredictor', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.PSResourceGet', 'posh-git', 'PowerShellForGitHub', 'Terminal-Icons')
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

### -PickModules
Choose which modules you want to install.

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
To Do
  Create basic starter profile if none exist
  Create dot-sourced profile
  Create interactive picker for packages and modules (separate functions)
  Bootstrap Out-GridView or Out-ConsoleGridView

## RELATED LINKS
