function Invoke-GitHubCliExtensionUpgrade {
    <#
    .SYNOPSIS
    Upgrades installed GitHub CLI extensions.

    .DESCRIPTION
    Invokes the GitHub CLI extension upgrade command and throws when it fails.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            & gh extension upgrade --all | Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command
    if ($ExitCode -ne 0) {
        throw "GitHub CLI extension upgrade failed with exit code $ExitCode."
    }
}
