---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-PowerShellPortable

## SYNOPSIS
Download a portable version of PowerShell 7x to run anywhere on demand.

## SYNTAX

```
Get-PowerShellPortable [[-Path] <String>] [-Extract] [<CommonParameters>]
```

## DESCRIPTION
This function helps you download a zipped version of PowerShell 7.x that can be run anywhere without needing to install it.

## EXAMPLES

### EXAMPLE 1
```
Get-PowerShellPortable -Path .\ -Extract
```

## PARAMETERS

### -Path
Path of the directory to download the PowerShell zip or tar.gz file into.

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

### -Extract
Extract the downloaded file.

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

## RELATED LINKS
