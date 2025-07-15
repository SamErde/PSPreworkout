function Get-HashtableValueType {
    <#
    .SYNOPSIS
    Get the object type of each value in a hashtable.

    .DESCRIPTION
    This function retrieves the object type information of each value in a hashtable and returns
    System.Reflection.TypeInfo objects with additional ItemKey properties for identification.
    Results can be filtered to a specific key using the Key parameter.

    .PARAMETER Hashtable
    The hashtable to inspect.

    .PARAMETER Key
    Optional. Specify a specific hashtable key to get the type information for only that key's value.
    If not specified, type information for all keys will be returned. Tab completion is available
    for this parameter based on the keys in the provided hashtable.

    .OUTPUTS
    System.Reflection.TypeInfo
    Type information objects for each hashtable entry, enhanced with an ItemKey property
    and formatted using the PSPreworkout.HashtableValueType custom type.

    .EXAMPLE
    Get-HashtableValueType -Hashtable @{ Key1 = 123; Key2 = "Hello"; Key3 = @(1, 2, 3) }

    Returns type information for all keys in the hashtable, sorted by key name.

    .EXAMPLE
    Get-HashtableValueType -Hashtable @{ Key1 = 123; Key2 = "Hello"; Key3 = @(1, 2, 3) } -Key "Key2"

    Returns type information only for the "Key2" entry (System.String).

    .EXAMPLE
    @{ Name = "John"; Age = 30; Active = $true } | Get-HashtableValueType

    Demonstrates pipeline input usage to analyze hashtable value types.

    .EXAMPLE
    $config = @{ "Server Name" = "web01"; Port = 8080; SSL = $true }
    Get-HashtableValueType $config -Key <TAB>

    Shows tab completion for keys, including proper quoting for keys with spaces.

    .NOTES
    This function is useful for debugging hashtables and understanding the data types of their values.
    The output includes custom formatting via PSPreworkout.Format.ps1xml for improved readability.

    .LINK
    about_Hashtables
    #>
    [CmdletBinding()]
    param (
        # The hashtable to inspect.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Hashtable,

        # Optional key to filter results to a specific hashtable entry.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        # Provide tab completion for the Key parameter based on the provided hashtable's keys.
        [ArgumentCompleter({
                param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
                [void]$CommandName, $ParameterName, $CommandAst
                # Get the hashtable from the bound parameters
                if ($FakeBoundParameters.ContainsKey('Hashtable')) {
                    $HashtableArg = $FakeBoundParameters['Hashtable']

                    # Return keys that match the current word being typed
                    $HashtableArg.Keys | Sort-Object | Where-Object { $_ -like "$WordToComplete*" } | ForEach-Object {
                        # Wrap in quotes if the key contains spaces or special characters
                        if ($_ -match '\s|[^\w]') {
                            "'$_'"
                        } else {
                            $_
                        }
                    }
                }
            })]
        [string]$Key
    )

    process {
        # Filter hashtable entries based on Key parameter if specified
        $EntriesToProcess = if ($PSBoundParameters.ContainsKey('Key')) {
            Write-Verbose "Filtering to specific key: [$Key]"
            if ($Hashtable.ContainsKey($Key)) {
                @{ $Key = $Hashtable[$Key] }.GetEnumerator() | Sort-Object -Property Key
            } else {
                Write-Warning "Key [$Key] not found in hashtable."
                @()
            }
        } else {
            Write-Verbose 'Processing all hashtable entries.'
            $Hashtable.GetEnumerator() | Sort-Object -Property Key
        }

        [System.Collections.Generic.List[System.Reflection.TypeInfo]]$ValueType = foreach ( $Item in $EntriesToProcess ) {
            Write-Verbose "Getting the object type of the value for [$($Item.Key)]."

            # Handle null values gracefully
            if ($null -eq $Item.Value) {
                Write-Verbose "Value for key [$($Item.Key)] is null, skipping type analysis."
                continue
            }
            [System.Reflection.TypeInfo]$ItemValueType = $Item.Value.GetType()

            # Set a custom format type name and add a NoteProperty to display the key.
            $ItemValueType.PSTypeNames.Insert(0, 'PSPreworkout.HashtableValueType')
            $ItemValueType | Add-Member -MemberType NoteProperty -Name 'ItemKey' -Value $Item.Key -Force
            $ItemValueType
        }

        # Output the list of type information for each entry
        $ValueType
    }
}
