---
document type: cmdlet
external help file: PSPreworkout-Help.xml
HelpUri: https://day3bits.com/PSPreworkout/Out-JsonFile
Locale: en-US
Module Name: PSPreworkout
ms.date: 01/23/2026
PlatyPS schema version: 2024-05-01
title: Out-JsonFile
---

# Out-JsonFile

## SYNOPSIS

Convert an object to JSON and write it to a file.

## SYNTAX

### __AllParameterSets

```
Out-JsonFile [-Object] <Object> [[-FilePath] <string>] [-Depth <int>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

This function converts an object to JSON and writes the output to the specified file.
By default, it saves the
file with the name of the object that you provided to the function.

## EXAMPLES

### EXAMPLE 1

Out-JsonFile -Object $TestObject -FilePath $HOME

Writes $TestObject as JSON to "$HOME/TestObject.json".

### EXAMPLE 2

Out-JsonFile -Object $TestObject -FilePath C:\Temp\report.json

Writes $TestObject as JSON to C:\Temp\report.json.

### EXAMPLE 3

Out-JsonFile -Object $TestObject

Writes $TestObject as JSON to TestObject.json in the current working directory of the file system.

## PARAMETERS

### -Depth

Depth to serialize the object into JSON.
Default is 2.

```yaml
Type: System.Int32
DefaultValue: 2
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

### -FilePath

Full path and filename to save the JSON to.
[ValidatePattern('\.json$')] # Do not require a JSON extension.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Object

The object to convert to JSON.
[ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_) -and -not [string]::IsNullOrEmpty($_)) { $true } })]

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
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

### System.Object

{{ Fill in the Description }}

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

