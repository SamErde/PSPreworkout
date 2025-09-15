function Write-PSPreworkoutTelemetry {
    <#
    .SYNOPSIS
        Keep track of how often each PSPreworkout command is used. No identifying information is sent.

    .DESCRIPTION
        This function sends anonymous statistics to the PostHog analytics service to help improve the PSPreworkout module.
        It sends the command being run, module version, PowerShell version, and OS version.

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
        # Event Name: The name of the function that was invoked.
        [Parameter(Mandatory, HelpMessage = 'The name of the function that was invoked.')]
        [string]
        $EventName,

        # The parameter names that were passed to the function that was invoked.
        [Parameter(Mandatory = $false, HelpMessage = 'The parameters passed to the function that was invoked.')]
        [string[]] $ParameterNamesOnly = @()
    )

    # Check which version of PSPreworkout is being used.
    try {
        $ModuleVersion = (Get-Module -Name PSPreworkout -ErrorAction Stop).Version.ToString()
    } catch {
        $ModuleVersion = '0.0.0'
        Write-Debug "The PSPreworkout module is not imported. $_"
    }

    Write-Verbose "Sending anonymous PowerShell and module version information to PostHog."

    # Define the JSON data
    $JsonData = @{
        api_key     = "phc_xBw0cWVLkbfYpNEJJU52Kkk4Cozh6OyVXxos2dPs3ro"
        distinct_id = Get-Random
        event       = "$EventName"
        properties  = @{
            # Module Details
            module_name        = "PSPreworkout"
            module_version     = "$ModuleVersion"

            # Session Details: Show unique sessions, but do not identify users.
            # The session_id is a combination of the process ID and a portion of the host instance ID.
            session_id         = [long]"$PID$(($Host.InstanceId -replace '[a-zA-Z]',''  -split '-')[0])"
            timestamp          = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')
            timezone           = (Get-TimeZone).Id

            # PowerShell Environment Details
            powershell_version = $PSVersionTable.PSVersion.ToString()
            powershell_edition = $PSVersionTable.PSEdition
            powershell_host    = $Host.Name
            execution_policy   = (Get-ExecutionPolicy -Scope CurrentUser).ToString()
            language_mode      = $ExecutionContext.SessionState.LanguageMode.ToString()

            # Operating System Details
            os_name            = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
            os_architecture    = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()

            # Command Context (if available)
            command_name       = "$EventName"
            parameters_used    = if ($ParameterNamesOnly) { $ParameterNamesOnly } else { $null }
        }
    }
    Write-Debug ($JsonData | ConvertTo-Json -Depth 3)

    $IrmSplat = @{
        UserAgent   = 'PSPreworkout-Telemetry-Script'
        Uri         = 'https://us.i.posthog.com/capture/'
        Method      = 'Post'
        ContentType = 'application/json'
        Body        = $JsonData | ConvertTo-Json -Depth 3
        Timeout     = 10
        ErrorAction = 'Stop'
    }

    try {
        Invoke-RestMethod @IrmSplat | Out-Null
    } catch {
        Write-Debug $_
    }
}
