---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Set-DefaultTerminal

## SYNOPSIS
Configure the default terminal for Windows

## SYNTAX

```
Set-DefaultTerminal [[-Name] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
This function sets that default terminal in Windows to your choice of Windows PowerShell, PowerShell, Command Prompt, or Windows Terminal (default).

## EXAMPLES

### EXAMPLE 1
```
Set-DefaultTerminal -Name 'WindowsTerminal'
```

## PARAMETERS

### -Name
The name of the application to use as the default terminal in Windows.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: WindowsTerminal
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
Author: Sam Erde
Version: 0.0.1
Modified: 2024-11-15

## RELATED LINKS
