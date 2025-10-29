---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Install-OhMyPosh

## SYNOPSIS
Install Oh My Posh and add it to your profile.

## SYNTAX

```
Install-OhMyPosh [-WingetSource <String>] [-Method <String>] [-InstallNerdFont] [-Font <String>]
 [<CommonParameters>]
```

## DESCRIPTION
An over-engineered script to install Oh My Posh.
This script exists as an exercise and is not intended for production use.

## EXAMPLES

### EXAMPLE 1
```
Install-OhMyPosh
```

## PARAMETERS

### -WingetSource
Specify which source to install from.

    - winget  - Install from winget (default).
    - msstore - Install from the Microsoft Store.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Winget
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
Specify which tool to install Oh My Posh with.

- chocolatey
- direct (default)
- scoop
- winget

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Direct
Accept pipeline input: False
Accept wildcard characters: False
```

### -InstallNerdFont
Use this switch if you want to install a nerd font for full glyph capabilities in your prompt.

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

### -Font
Choose a nerd font to install.

- Default - Installs "Meslo" as the default nerd font.
- Select  - Lets you choose a nerd font from the list.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Default
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
Version: 0.1.0
Modified: 2024-10-23

## RELATED LINKS
