function Get-HashtableValueType {
    <#
    .SYNOPSIS
    Get the object type of each value in a hashtable.

    .DESCRIPTION
    This function retrieves the object type information of each value in a hashtable.

    .PARAMETER Hashtable
    The hashtable to inspect.

    .OUTPUTS
    System.Collections.Generic.List[System.Reflection.TypeInfo]
    A list containing type information for each value in the hashtable.

    .EXAMPLE
    Get-HashtableValueType -Hashtable @{ Key1 = 123; Key2 = "Hello"; Key3 = @(1, 2, 3) }

    Key   Value     Type            TypeName
    ---   -----     ----            --------
    Key3  {1, 2, 3} System.Object[] System.Object[]
    Key2  Hello     System.String   System.String
    Key1  123       System.Int32    System.Int32

    .EXAMPLE
    @{ Name = "John"; Age = 30; Active = $true } | Get-HashtableValueType

    This example demonstrates pipeline input usage.

    .NOTES
    This function is useful for debugging a hashtable and understanding the data types of its values.
    #>
    [CmdletBinding()]
    param (
        # The hashtable to inspect.
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Hashtable
    )

    begin {
        Write-Verbose 'Initializing the list to hold type information.'
        [System.Collections.Generic.List[System.Reflection.TypeInfo]]$ValueType = @()
    }

    process {
        $ValueType = foreach ( $Item in ($Hashtable.GetEnumerator() | Sort-Object) ) {
            Write-Verbose "Getting the object type of the value for [$($Item.Key)]."
            [System.Reflection.TypeInfo]$ItemValueType = $Item.Value.GetType()

            # Set a custom format type name and add a NoteProperty to display the key.
            $ItemValueType.PSTypeNames.Insert(0, 'PSPreworkout.HashtableValueType')
            $ItemValueType | Add-Member -MemberType NoteProperty -Name 'ItemKey' -Value $Item.Key -Force
            $ItemValueType
        }

        # Output the list of type information for each entry
        $ValueType
    }

    end {}
}
