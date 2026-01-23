---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Install-WinGet
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Install-WinGet
---

# Install-WinGet

## SYNOPSIS

Install Winget (beta)

## SYNTAX

### __AllParameterSets

```
Install-WinGet [[-DownloadPath] <string>] [-DownloadOnly] [-KeepDownload] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Install WinGet on Windows Sandbox (or on builds of Windows 10 prior to build 1709 that did not ship with it
preinstalled).
This script exists mostly as an exercise, as there are already many ways to install WinGet.

## EXAMPLES

### EXAMPLE 1

Install-WinGet

### EXAMPLE 2

Install-WinGet -KeepDownload

Installs WinGet and keeps the downloaded AppX packages.

## PARAMETERS

### -DownloadOnly

Download the packages without installing them (optional).

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

### -DownloadPath

Path of the directory to save the downloaded packages in (optional).

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -KeepDownload

Keep the downloaded packages (optional).

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
Version: 0.1.0
Modified: 2024-10-23

To Do:
- Check for newer versions of packages on GitHub
- Error handling
- Create the target folder if it does not already exist


## RELATED LINKS

{{ Fill in the related links here }}

