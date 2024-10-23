function Show-WithoutEmptyProperty {
    <#
    .SYNOPSIS
    Show an object without its empty properties.

    .DESCRIPTION
    This function shows the properties of an object with all of its empty properties filtered out.

    .PARAMETER Object
    The object to show.

    .EXAMPLE
    Show-WithoutEmptyProperty -Object $Object

    .EXAMPLE
    $Desk = [PSCustomObject]@{
        Model = 'PSDesk'
        Height = $null
        Width = $null
        Colors = @('Black', 'Gray')
        Adjustable = $true
    }
    $Object = New-Object -TypeName PSObject -Property $Desk
    Show-WithoutEmptyProperty -Object $Object

    This example creates an object from a hash table and then shows that object's properties that have values.

    .EXAMPLE
    Show-WithoutEmptyProperty -Object (Get-Item $HOME)

    This example gets the home folder object while invoking the function.

    .EXAMPLE
    $Object | Show-WithoutEmptyProperty

    This example shows how an object can be piped to the function.

    .EXAMPLE
    Get-ChildItem $HOME | Select-Object -First 1 | Show-WithoutEmptyProperty

    This example gets the home folder object and pipes it to the Show-WithoutEmptyProperty function.

    .NOTES
    I am grateful to Jeffrey Hicks for guiding me towards an understanding of how to complete this function and for
    providing even nicer code than I started with. I encourage you to reach out to him for PowerShell training and
    subscribe to his newsletter! 🙏

        https://jdhitsolutions.github.io/
        https://www.linkedin.com/in/jefferyhicks/
        https://twitter.com/JeffHicks
    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Show-WithoutEmptyProperty')]
    [OutputType('PSCustomObject')]
    param (
        # The object to show without empty properties
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Object]
        $Object
    )

    begin {

    }

    process {
        $Object.PSObject.Properties | Where-Object {
            $_.Value
        } | ForEach-Object -Begin {
            $JDHIT = [ordered]@{}
            [void]$JDHIT # Suppress code analyzer errors during build.
        } -Process {
            $JDHIT.Add($_.name, $_.Value)
        } -End {
            New-Object -TypeName PSObject -Property $JDHIT
        }
    }

    end {

    }
}
