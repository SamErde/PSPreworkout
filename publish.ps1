param  (
  [string] $PSGalleryApiKey
)

# Purpose: Cleans the module directory to prepare for publication to PowerShell Gallery
$ErrorActionPreference = 'stop'
$ModulePath = "./src/PSPreworkout"

# Build directory should work on Windows or Linux
$BuildDirectory = $env:TEMP ? "$env:TEMP/Build" : "/tmp/Build"

# These project paths will be excluded from the module during publishing
$Exclude = @(
)

# Copy project to temporary build directory
if (Test-Path -Path $BuildDirectory) {
  Remove-Item -Path $BuildDirectory -Recurse -Force
}
$null = New-Item -ItemType Directory -Path $BuildDirectory
Write-Host -Object 'Created build directory'
Copy-Item -Exclude $Exclude -Path $ModulePath/* -Destination $BuildDirectory -Recurse
Write-Host -Object 'Copied all items to build directory'

Publish-Module -Path $BuildDirectory -NuGetApiKey $PSGalleryApiKey
