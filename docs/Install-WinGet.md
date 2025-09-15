---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Install-WinGet

## SYNOPSIS
Install Winget (beta)

## SYNTAX

```
Install-WinGet [[-DownloadPath] <String>] [-DownloadOnly] [-KeepDownload]
 [<CommonParameters>]
```

## DESCRIPTION
Install WinGet on Windows Sandbox (or on builds of Windows 10 prior to build 1709 that did not ship with it
preinstalled).
This script exists mostly as an exercise, as there are already many ways to install WinGet.

## EXAMPLES

### EXAMPLE 1
```
Install-WinGet
```

### EXAMPLE 2
```
Install-WinGet -KeepDownload
```

Installs WinGet and keeps the downloaded AppX packages.

## PARAMETERS

### -DownloadPath
Path of the directory to save the downloaded packages in (optional).

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

### -DownloadOnly
Download the packages without installing them (optional).

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

### -KeepDownload
Keep the downloaded packages (optional).

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
Author: Sam Erde
Version: 0.1.0
Modified: 2024-10-23

To Do:
- Check for newer versions of packages on GitHub
- Error handling
- Create the target folder if it does not already exist

## RELATED LINKS
