---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Initialize-PSEnvironmentConfiguration
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Initialize-PSEnvironmentConfiguration
---

# Initialize-PSEnvironmentConfiguration

## SYNOPSIS

Initialize configuration your PowerShell environment and git.

## SYNTAX

### __AllParameterSets

```
Initialize-PSEnvironmentConfiguration [-Name] <string> [-Email] <string> [[-Font] <string>]
 [[-Packages] <string[]>] [[-Modules] <string[]>] [-SkipPackages] [-SkipModules]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Install supporting packages, configure git, and set your console font with this function.

## EXAMPLES

### EXAMPLE 1

Initialize the PowerShell working environment with a custom font, and set my name and email address for Git commits.

Initialize-PSEnvironmentConfiguration -Name 'Sam Erde' -Email 'sam@example.local' -ConsoleFont 'FiraCode Nerd Font'

## PARAMETERS

### -Email

Your email to be used for git commits.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Font

The font to use for your consoles (PowerShell, Windows PowerShell, git bash, etc.)

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Modules

PowerShell modules to install.

```yaml
Type: System.String[]
DefaultValue: "@('CompletionPredictor', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.PSResourceGet', 'posh-git', 'PowerShellForGitHub', 'Terminal-Icons', 'PSReadLine', 'PowerShellGet')"
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 4
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Name

Your name to be used for git commits.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Packages

Packages to install with winget.

```yaml
Type: System.String[]
DefaultValue: "@('Microsoft.WindowsTerminal', 'git.git', 'JanDeDobbeleer.OhMyPosh')"
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SkipModules

Option to skip installation of default modules.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SkipPackages

Option to skip installation of default packages.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

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

{{ Fill in the related links here }}

