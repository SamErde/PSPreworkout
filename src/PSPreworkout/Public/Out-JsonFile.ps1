function Out-JsonFile {
    <#
    .SYNOPSIS
    Convert an object to JSON and write it to a file.

    .DESCRIPTION
    This function converts an object to JSON and writes the output to the specified file. By default, it saves the
    file with the name of the object that you provided to the function.

    .EXAMPLE
    Out-JsonFile -Object $TestObject -FilePath $HOME

    Writes $TestObject as JSON to "$HOME/TestObject.json".

    .EXAMPLE
    Out-JsonFile -Object $TestObject -FilePath C:\Temp\report.json

    Writes $TestObject as JSON to C:\Temp\report.json.

    .EXAMPLE
    Out-JsonFile -Object $TestObject

    Writes $TestObject as JSON to TestObject.json in the current working directory of the file system.
    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/Out-JsonFile')]
    param (
        # The object to convert to JSON.
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        # [ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_) -and -not [string]::IsNullOrEmpty($_)) { $true } })]
        [Object]
        $Object,

        # Depth to serialize the object into JSON. Default is 2.
        [Parameter()]
        [Int32]
        $Depth = 2,

        # Full path and filename to save the JSON to.
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        # [ValidatePattern('\.json$')] # Do not require a JSON extension.
        [ValidateScript({
                if ((Split-Path -Path $_).Length -gt 0) {
                    if (Test-Path -Path (Split-Path -Path $_) -PathType Container) {
                        $true
                    } else {
                        throw "The directory `'$(Split-Path -Path $_)`' was not found."
                    }
                } else { $true }
            })]
        [string]
        $FilePath
    )

    begin {
        # Send non-identifying usage statistics to PostHog.
        Write-PSPreworkoutTelemetry -EventName $MyInvocation.MyCommand.Name -ParameterNamesOnly $MyInvocation.BoundParameters.Keys

        # Validate the file path and extension.
        if ($FilePath) {
            # Ensure that a working directory is included in filepath.
            if ([string]::IsNullOrEmpty([System.IO.Path]::GetDirectoryName($FilePath))) {
                $FilePath = Join-Path -Path (Get-Location -PSProvider FileSystem).Path -ChildPath $FilePath
            }

            # To Do: Check for a bare directory path and add a filename to it.
            $OutFile = $FilePath

        } else {
            # If $FilePath is not specified then set $Path to the current location of the FileSystem provider.
            [string]$Path = (Get-Location -PSProvider FileSystem).Path

            # Set the file name to be the same as the name of the object passed in the first parameter (providing it has a name).
            $ObjectName = "$($PSCmdlet.MyInvocation.Statement.Split('$')[1])"
            if ([string]::IsNullOrEmpty($ObjectName)) {
                # Just name the file "Object.json" if no filename or object name is present.
                $OutFile = Join-Path -Path $Path -ChildPath 'Object.json'
            } else {
                $OutFile = Join-Path -Path $Path -ChildPath "${ObjectName}.json"
            }
        }
    } # end begin block

    process {
        try {
            $Object | ConvertTo-Json -Depth $Depth | Out-File -FilePath $OutFile -Force
        } catch {
            throw "Failed to convert object to JSON and write to file: $_"
        }
    } # end process block

}
