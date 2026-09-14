function Invoke-GitHubCopilotCliUpdate {
    <#
    .SYNOPSIS
    Updates the GitHub Copilot CLI.

    .DESCRIPTION
    Invokes the GitHub Copilot CLI update command and throws when it fails.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            & copilot update | Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command
    if ($ExitCode -ne 0) {
        throw "GitHub Copilot CLI update failed with exit code $ExitCode."
    }
}
