---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Set-EnvironmentVariable

## SYNOPSIS
Set environment variables.

## SYNTAX

```
Set-EnvironmentVariable [-Name] <String> [-Value] <String> [-Target] <EnvironmentVariableTarget>
 [<CommonParameters>]
```

## DESCRIPTION
Set environment variables in any OS using .NET types.

## EXAMPLES

### EXAMPLE 1
```
Set-EnvironmentVariable -Name 'FavoriteDrink' -Value 'Coffee' -Target 'User'
```

## PARAMETERS

### -Name
Parameter description

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

### -Value
Parameter description

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

### -Target
Parameter description

```yaml
Type: EnvironmentVariableTarget
Parameter Sets: (All)
Aliases:
Accepted values: Process, User, Machine

Required: True
Position: 3
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

## RELATED LINKS
