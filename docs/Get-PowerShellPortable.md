---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Get-PowerShellPortable
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Get-PowerShellPortable
---

# Get-PowerShellPortable

## SYNOPSIS

Download a portable version of PowerShell to run anywhere on demand.

## SYNTAX

### __AllParameterSets

```
Get-PowerShellPortable [[-Path] <string>] [-Extract] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function helps you download a zipped copy of the latest version of PowerShell that can be run without needing to install it.

## EXAMPLES

### EXAMPLE 1

Get-PowerShellPortable -Path $HOME -Extract

Download the latest ZIP/TAR of PowerShell to your $HOME folder.
It will be extracted into a folder that matches the filename of the compressed archive.

## PARAMETERS

### -Extract

Extract the file after downloading.

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

### -Path

The directory path to download the PowerShell zip or tar.gz file into.
Do not include a filename for the download.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

