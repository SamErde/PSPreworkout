---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Install-PowerShellISE

## SYNOPSIS
Install the Windows PowerShell ISE

## SYNTAX

```
Install-PowerShellISE [<CommonParameters>]
```

## DESCRIPTION
This script installs Windows PowerShell ISE if it was not installed or previously removed.
It includes a step that
temporarily resets the Windows Automatic Update server source in the registry, which may resolve errors that some
systems experience while trying to add Windows Capabilities.

## EXAMPLES

### EXAMPLE 1
```
Install-PowerShellISE
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Sam Erde
Version: 1.0.0
Modified: 2025-01-07

To Do: Add parameter to make the Windows Update registry change optional.

## RELATED LINKS
