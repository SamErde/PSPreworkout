function Test {
    [CmdletBinding()]
    param (

        # Full path and filename to save the JSON to.
        [Parameter(Position = 1)]
        [ValidatePattern('\.json$')]
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

    Write-Host $FilePath
}

Test 'test.json'
Test "$env:Temp\test.json"
Test
