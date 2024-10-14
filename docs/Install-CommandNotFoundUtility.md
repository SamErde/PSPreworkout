---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Install-CommandNotFoundUtility

## SYNOPSIS
Install and setup the WinGetCommandNotFound utility from Microsoft PowerToys.

## SYNTAX

```
Install-CommandNotFoundUtility [<CommonParameters>]
```

## DESCRIPTION
This script installs the Microsoft.WinGet.CommandNotFound module and
enables the required experimental features in PowerShell 7.

## EXAMPLES

### EXAMPLE 1
```
Install-CommandNotFoundUtility
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Sam Erde
Version: 0.0.1
Modified: 2024-10-14

May not work with PowerShell installed from MSIX or the Microsoft Store: \<https://github.com/microsoft/PowerToys/issues/30818\>

requires -Version 7.4

## RELATED LINKS
