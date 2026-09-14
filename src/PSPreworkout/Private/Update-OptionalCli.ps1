function Update-OptionalCli {
    <#
    .SYNOPSIS
    Updates an optional command-line tool.

    .DESCRIPTION
    Runs a supplied update command when its command-line tool is installed.

    .PARAMETER CommandName
    The command used to detect whether the tool is installed.

    .PARAMETER DisplayName
    The status text displayed to the user.

    .PARAMETER CurrentOperation
    The operation shown in the progress record.

    .PARAMETER TargetName
    The ShouldProcess target.

    .PARAMETER ActionName
    The ShouldProcess action.

    .PARAMETER PercentComplete
    The overall completion percentage.

    .PARAMETER UpdateCommand
    The update operation to invoke.

    .OUTPUTS
    None
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CommandName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentOperation,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ActionName,

        [Parameter(Mandatory)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [scriptblock]$UpdateCommand
    )

    if (-not (Test-PSPreworkoutCommand -Name $CommandName)) {
        Write-Verbose "$DisplayName was skipped because $CommandName was not found."
        return
    }

    Write-Information $DisplayName -InformationAction Continue
    Write-UpdateAllTheThingsProgress -CurrentOperation $CurrentOperation -PercentComplete $PercentComplete
    if ($PSCmdlet.ShouldProcess($TargetName, $ActionName)) {
        & $UpdateCommand
    }
}
