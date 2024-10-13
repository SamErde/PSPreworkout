---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Get-EnvironmentVariable

## SYNOPSIS
Retrieves the value of an environment variable.

## SYNTAX

```
Get-EnvironmentVariable [[-Name] <String>] [[-Target] <EnvironmentVariableTarget>] [-All]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-EnvironmentVariable function retrieves the value of the specified environment variable
or displays all environment variables.

## EXAMPLES

### EXAMPLE 1
```
Get-EnvironmentVariable -Name "PATH"
Retrieves the value of the "PATH" environment variable.
```

## PARAMETERS

### -Name
The name of the environment variable to retrieve.

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

### -Target
The target of the environment variable to retrieve.
Defaults to User.
(Process, User, or Machine)

```yaml
Type: EnvironmentVariableTarget
Parameter Sets: (All)
Aliases:
Accepted values: Process, User, Machine

Required: False
Position: 2
Default value: User
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Switch to show environment variables in all target scopes.

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

### System.String
## NOTES
Author: Sam Erde
Version: 0.0.2
Modified: 2024/10/12

Variable names are case-sensitive on Linux and macOS, but not on Windows.

Why is 'Target' used by .NET instead of the familiar 'Scope' parameter name?
@IISResetMe (Mathias R.
Jessen) explains:
"Scope" would imply some sort of integrated hierarchy of env variables - that's not really the case.
Target=Process translates to kernel32!GetEnvironmentVariable (which then in turn reads the PEB from
the calling process), whereas Target={User,Machine} causes a registry lookup against environment
data in either HKCU or HKLM.

The relevant sources for the User and Machine targets are in the registry at:
- HKEY_CURRENT_USER\Environment
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment

See more at \<https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables\>.

## RELATED LINKS
