param  (
    [string] $PSGalleryApiKey
)

$ErrorActionPreference = 'stop'
$ModulePath = './src/PSPreworkout'

Publish-Module -Path $ModulePath -NuGetApiKey $PSGalleryApiKey
