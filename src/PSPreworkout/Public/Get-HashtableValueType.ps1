function Get-HashtableValueType {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable]$Hashtable
    )

    begin {}

    process {
        foreach ($entry in $Hashtable.GetEnumerator()) {
            [pscustomobject]@{
                Name     = $entry.Name
                TypeName = $entry.Value.GetType().Name
                BaseType = $entry.Value.GetType().BaseType
            }
        }
    }

    end {}
}