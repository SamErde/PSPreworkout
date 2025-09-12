function Write-PSPreworkoutTelemetry {
<#
.SYNOPSIS
    Keep track of how often each PSPreworkout command is used.

.DESCRIPTION
    This function sends anonymous telemetry data to PostHog analytics service to help improve the PSPreworkout module.
    It sends the command being run, PowerShell version, OS version, and module version.

.PARAMETER EventName
    The name of the telemetry event to record. Most likely a function name.

.EXAMPLE
    Write-PSPreworkoutTelemetry -EventName "Get-EnvironmentVariable"

.EXAMPLE
    Write-PSPreworkoutTelemetry -EventName "Get-ModulesWithUpdate"

.NOTES
    This function requires an internet connection to send telemetry data.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = 'The name of the function being invoked.')]
        [string]
        $EventName
    )
    Write-Verbose "Sending PowerShell and module version information to PostHog."

    # Check which version of PSPreworkout is being used.
    try {
        $ModuleVersion = (Get-Module -Name PSPreworkout -ErrorAction Stop).Version.ToString()
    } catch {
        $ModuleVersion = '0.0.0'
        Write-Debug "The PSPreworkout module is not imported. $_"
    }

    # Define the JSON data
    $jsonData = @{
        api_key            = "phc_xBw0cWVLkbfYpNEJJU52Kkk4Cozh6OyVXxos2dPs3ro"
        event              = $EventName
        powershell_version = $PSVersionTable.PSVersion.ToString()
        os_version         = (Get-CimInstance Win32_OperatingSystem).Version
        module_version     = $ModuleVersion
    }

    $IrmSplat = @{
        UserAgent   = 'PSPreworkout-Telemetry-Script'
        Url         = 'https://us.i.posthog.com/capture/'
        Method      = 'Post'
        ContentType = 'application/json'
        Body        = $jsonData | ConvertTo-Json
        Timeout     = 10
        ErrorAction = 'Stop'
    }

    try {
        Invoke-RestMethod @IrmSplat | Out-Null
    } catch {
        Write-Debug $_
    }
}
