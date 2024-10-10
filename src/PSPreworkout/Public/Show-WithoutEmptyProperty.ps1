function Show-WithoutEmptyProperty {
    <#
    .SYNOPSIS
    Show an object without its empty properties.

    .DESCRIPTION
    Show the properties of an object with all of its empty properties filtered out.

    .PARAMETER Object
    The object to view properties of.

    .EXAMPLE
    Show-WithoutEmptyProperty

    #>
    [CmdletBinding()]
    [OutputType('OrderedDictionary')]
    param (
        # The object to show without empty properties
        [Parameter(Mandatory)]
        [Object]
        $Object
    )

    $PropertiesWithValues = [Ordered]@{}
    foreach ($property in $Object.PSObject.Properties) {
        if ($property.Value) {
            $PropertiesWithValues[$property.Name] = $property.Value
        }
    }
    $PropertiesWithValues
}
