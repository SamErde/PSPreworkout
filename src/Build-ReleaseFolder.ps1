function Build-ReleaseFolder {
    [CmdletBinding()]
    param ()

    $ReleaseFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\Release\'
    if (-not (Test-Path -Path $ReleaseFolder)) {
        New-Item -Path (Split-Path $ReleaseFolder -Parent) -ItemType Directory -Name (Split-Path $ReleaseFolder -Leaf)
    }
    $ReleaseFolder = Resolve-Path $ReleaseFolder
    $ArtifactsFolder = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '.\Artifacts')
    $ExternalHelpFolder = Get-ChildItem -Directory -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\docs\') | Select-Object -ExpandProperty FullName

    Copy-Item -Path $ArtifactsFolder\* -Destination "$ReleaseFolder" -Recurse -Exclude @('ccReport', 'testOutput', 'Release', 'PSPreworkout.zip') -Force
    Copy-Item -Path $ExternalHelpFolder -Destination $ReleaseFolder -Recurse -Force

}

Build-ReleaseFolder
