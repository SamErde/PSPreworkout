function Write-UpdateAllTheThingsProgress {
    <#
    .SYNOPSIS
    Writes progress for Update-AllTheThings.

    .DESCRIPTION
    Centralizes the parent progress record used by Update-AllTheThings and its
    private update helpers.

    .PARAMETER CurrentOperation
    The operation currently being performed.

    .PARAMETER PercentComplete
    The percentage of the overall update that is complete.

    .PARAMETER Completed
    Completes and removes the progress record.

    .OUTPUTS
    None
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentOperation,

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$PercentComplete = 0,

        [Parameter()]
        [switch]$Completed
    )

    if ($Completed) {
        Write-Progress -Id 0 -Activity 'Update Everything' -Completed
        return
    }

    $ProgressParameters = @{
        Id               = 0
        Activity         = 'Update Everything'
        CurrentOperation = $CurrentOperation
        Status           = "Progress: $PercentComplete`% Complete"
        PercentComplete  = $PercentComplete
    }
    Write-Progress @ProgressParameters
}
