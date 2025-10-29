---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Update-AllTheThings

## SYNOPSIS
Update all the things!

## SYNTAX

```
Update-AllTheThings [-SkipModules] [-SkipScripts] [-SkipHelp] [-SkipWinGet] [-IncludeChocolatey]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
A script to automatically update all PowerShell modules, PowerShell Help, and packages (apt, brew, chocolately, winget).

## EXAMPLES

### EXAMPLE 1
```
Update-AllTheThings
```

Updates all of the things it can!

## PARAMETERS

### -SkipModules
Skip the step that updates PowerShell modules.

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

### -SkipScripts
Skip the step that updates PowerShell scripts.

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

### -SkipHelp
Skip the step that updates PowerShell help.

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

### -SkipWinGet
Skip the step the updates WinGet packages.

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

### -IncludeChocolatey
Include Chocolatey package updates.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: SkipChoco

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
Author: Sam Erde
Version: 0.5.10

## RELATED LINKS
