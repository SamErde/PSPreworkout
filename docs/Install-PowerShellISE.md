---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables
schema: 2.0.0
---

# Install-PowerShellISE

## SYNOPSIS
Install the Windows PowerShell ISE if you removed it after installing VS Code.

## SYNTAX

```
Install-PowerShellISE [<CommonParameters>]
```

## DESCRIPTION
This script installs the Windows PowerShell ISE if it is not already.
It includes a step that resets the Windows
Automatic Update server source in the registry temporary, which may resolve errors that some people experience
while trying to add Windows Capabilities.
This was created because Out-GridView in Windows PowerShell 5.1 does not
work without the ISE installed.
However, Out-GridView was rewritten and included in PowerShell 7 for Windows.

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
To Do:
    - Check for Windows client vs Windows Server OS
    - Add parameter to make the Windows Update registry change optional
    - Requires admin but adding that breaks the build

## RELATED LINKS
