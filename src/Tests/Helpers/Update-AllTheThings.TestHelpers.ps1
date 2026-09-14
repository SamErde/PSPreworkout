$ModuleRoot = [System.IO.Path]::GetFullPath(
    (Join-Path -Path $PSScriptRoot -ChildPath '..\..\PSPreworkout')
)

$PrivatePaths = @(
    'Test-PSPreworkoutCommand.ps1'
    'Get-PSPreworkoutPlatform.ps1'
    'Write-UpdateAllTheThingsProgress.ps1'
    'Invoke-UpdateNativeCommand.ps1'
    'Get-CimOperatingSystemCaption.ps1'
    'Get-WmiOperatingSystemCaption.ps1'
    'Get-WindowsOperatingSystemCaption.ps1'
    'Read-WinGetServerChoice.ps1'
    'Invoke-WinGetUpgrade.ps1'
    'Invoke-GitHubCliExtensionUpgrade.ps1'
    'Invoke-GitHubCopilotCliUpdate.ps1'
    'Set-UpdateRepositoryTrust.ps1'
    'Update-PowerShellArtifact.ps1'
    'Update-WinGetPackage.ps1'
    'Update-LinuxPackage.ps1'
    'Update-MacOSPackage.ps1'
    'Update-OptionalCli.ps1'
    'Update-ChocolateyPackage.ps1'
    'Write-PSPreworkoutTelemetry.ps1'
)

foreach ($PrivatePath in $PrivatePaths) {
    . (Join-Path -Path $ModuleRoot -ChildPath "Private\$PrivatePath")
}

. (Join-Path -Path $ModuleRoot -ChildPath 'Public\Test-IsElevated.ps1')
. (Join-Path -Path $ModuleRoot -ChildPath 'Public\Update-AllTheThings.ps1')
