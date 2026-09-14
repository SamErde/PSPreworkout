function Invoke-UpdateNativeCommand {
    <#
    .SYNOPSIS
    Invokes a native update command and validates its exit code.

    .DESCRIPTION
    Provides consistent invocation and explicit failure handling for native
    package-manager commands.

    .PARAMETER Name
    The native command to invoke.

    .PARAMETER ArgumentList
    Arguments passed to the native command.

    .PARAMETER FailureMessage
    Context included in the terminating error when the command fails.

    .PARAMETER Command
    An invocation seam used by unit tests.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [AllowEmptyCollection()]
        [string[]]$ArgumentList = @(),

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FailureMessage,

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [scriptblock]$Command = {
            param($CommandName, $CommandArguments)

            & $CommandName @CommandArguments | Out-Host
            return $LASTEXITCODE
        }
    )

    $ExitCode = & $Command $Name $ArgumentList
    if ($ExitCode -ne 0) {
        throw "$FailureMessage failed with exit code $ExitCode."
    }
}
