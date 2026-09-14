<#
.SYNOPSIS
Runs the focused Update-AllTheThings compatibility tests.

.DESCRIPTION
Installs the supported Pester version when necessary and runs the focused test
files used by the cross-platform GitHub Actions matrix.
#>

[CmdletBinding()]
param()

$PesterVersion = [version]'5.9.1'
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$InstalledPester = Get-Module -ListAvailable -Name Pester |
    Where-Object Version -EQ $PesterVersion |
    Select-Object -First 1

if (-not $InstalledPester) {
    Install-Module -Name Pester -RequiredVersion $PesterVersion -Scope CurrentUser -Force -SkipPublisherCheck
}

Import-Module -Name Pester -RequiredVersion $PesterVersion -Force

$Configuration = New-PesterConfiguration
$Configuration.Run.Path = @(
    (Join-Path -Path $PSScriptRoot -ChildPath 'Unit\Update-AllTheThings.Contract.Tests.ps1')
    (Join-Path -Path $PSScriptRoot -ChildPath 'Unit\Update-AllTheThings.Cli.Tests.ps1')
    (Join-Path -Path $PSScriptRoot -ChildPath 'Unit\Update-AllTheThings.WinGet.Tests.ps1')
    (Join-Path -Path $PSScriptRoot -ChildPath 'Unit\Update-AllTheThings.Helpers.Tests.ps1')
    (Join-Path -Path $PSScriptRoot -ChildPath 'Unit\Update-AllTheThings.Package.Tests.ps1')
)
$Configuration.Run.Exit = $true
$Configuration.Output.Verbosity = 'Detailed'

Invoke-Pester -Configuration $Configuration
