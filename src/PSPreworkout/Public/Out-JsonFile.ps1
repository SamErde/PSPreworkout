function Out-JsonFile {
    <#
    .SYNOPSIS
        Convert an object to JSON and write to a file.

    .DESCRIPTION
        This function converts an object to JSON and writes the output to the specified file. By default, it saves the
        file with the name of the object that you provided to the function.

    .EXAMPLE
        Out-JsonFile -Object $TestObject

        Writes the $TestObject as JSON to 'TestObject.json'.

    .NOTES
        Author: Sam Erde
        Version: 0.0.1
        Modified: 2024/10/10

        To-Do:
            Add error handling for objects that cannot be converted to JSON.
            Validate JSON?
    #>
    [CmdletBinding()]
    param (
        # Object to convert to JSON and save to a file
        [Parameter(Mandatory, Position = 0)]
        [Object]
        $Object,

        # Path to save files in
        [Parameter(Position = 1)]
        [string]
        $Path = $PWD
    )

    # Get the passed object name from the first parameter to use as the filename
    $ObjectName = "$($PSCmdlet.MyInvocation.Statement.Split('$')[1])"
    $Object | ConvertTo-Json | Out-File -FilePath (Join-Path -Path $Path -ChildPath "${ObjectName}.json") -Force
}
