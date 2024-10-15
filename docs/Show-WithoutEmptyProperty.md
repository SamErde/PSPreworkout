---
external help file: PSPreworkout-help.xml
Module Name: PSPreworkout
online version:
schema: 2.0.0
---

# Show-WithoutEmptyProperty

## SYNOPSIS
Show an object without its empty properties.

## SYNTAX

```
Show-WithoutEmptyProperty [-Object] <Object> [<CommonParameters>]
```

## DESCRIPTION
This function shows the properties of an object with all of its empty properties filtered out.

## EXAMPLES

### EXAMPLE 1
```
Show-WithoutEmptyProperty -Object $Object
```

### EXAMPLE 2
```
[PSCustomObject]$Desk = @{
    Model = 'PSDesk'
    Height = $null
    Width = $null
    Colors = @('Black', 'Gray')
    Adjustable = $true
}
$Object = New-Object -TypeName PSObject -Property $Desk
Show-WithoutEmptyProperty -Object $Object
```

This example creates an object from a hash table and then shows that object's properties that have values.

### EXAMPLE 3
```
Show-WithoutEmptyProperty -Object (Get-Item $HOME)
```

This example gets the home folder object while invoking the function.

### EXAMPLE 4
```
$Object | Show-WithoutEmptyProperty
```

This example shows how an object can be piped to the function.

### EXAMPLE 5
```
Get-ChildItem $HOME | Select-Object -First 1 | Show-WithoutEmptyProperty
```

This example gets the home folder object and pipes it to the Show-WithoutEmptyProperty function.

## PARAMETERS

### -Object
The object to show.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSCustomObject
## NOTES
I am grateful to Jeffrey Hicks for guiding me towards an understanding of how to complete this function and for
providing even nicer code than I started with.
I encourage you to reach out to him for PowerShell training and
subscribe to his newsletter!
🙏

    https://jdhitsolutions.github.io/
    https://www.linkedin.com/in/jefferyhicks/
    https://twitter.com/JeffHicks

## RELATED LINKS
