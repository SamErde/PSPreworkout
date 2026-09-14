function Invoke-WinGetUpgrade {
    <#
    .SYNOPSIS
    Upgrades all user-scoped WinGet packages.

    .DESCRIPTION
    Invokes WinGet non-interactively and throws when WinGet reports a failure.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            & winget upgrade --silent --scope user --accept-package-agreements --accept-source-agreements --all |
                Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command
    if ($ExitCode -ne 0) {
        throw "WinGet package upgrade failed with exit code $ExitCode."
    }
}
