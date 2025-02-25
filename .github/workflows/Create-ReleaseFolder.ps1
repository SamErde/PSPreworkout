$ReleaseFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\Artifacts\Release\'
if (-not (Test-Path -Path $ReleaseFolder)) {
    New-Item -Path (Split-Path $ReleaseFolder -Parent) -ItemType Directory -Name (Split-Path $ReleaseFolder -Leaf)
}
$ReleaseFolder = Resolve-Path $ReleaseFolder
$ArtifactsFolder = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\Artifacts')
$ExternalHelpFolder = Get-ChildItem -Directory -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\..\docs') | Select-Object -ExpandProperty FullName

Copy-Item -Path $ArtifactsFolder\* -Destination "$ReleaseFolder" -Recurse -Exclude @('ccReport', 'testOutput', 'Release', 'PSPreworkout.zip') -Force
Copy-Item -Path $ExternalHelpFolder -Destination $ReleaseFolder -Recurse -Force
