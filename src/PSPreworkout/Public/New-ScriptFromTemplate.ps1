function New-ScriptFromTemplate {
    <#
        .SYNOPSIS
        Create a new advanced function from a template.

        .DESCRIPTION
        This function creates a new function from a template and saves it to a file with the name of the function.
        It takes values for the function's synopsis, description, and alias as parameters and populates comment-
        based help for the new function automatically.

        .PARAMETER Name
        The name of the new function to create. It is recommended to use ApprovedVerb-Noun for names.

        .PARAMETER Synopsis
        A synopsis of the new function.

        .PARAMETER Description
        A description of the new function.

        .PARAMETER Alias
        Optionally define an alias for the new function.

        .PARAMETER Author
        Name of the author of the script. Attempts to default to the 'FullName' property of the currently logged in user.

        .PARAMETER Path
        The path of the directory to save the new script in.

        .PARAMETER SkipValidation
        Optionally skip validation of the script name. This will not check for use of approved verbs or restricted characters.

        .EXAMPLE
        New-ScriptFromTemplate -Name 'Get-Demo' -Synopsis 'Get a demo.' -Description 'This function gets a demo.' -Alias 'Get-Sample' -Parameter 'SerialNumber'

        .EXAMPLE
        New-ScriptFromTemplate -Verb Get -Noun Something -Author 'Sam Erde' -Parameter @('Name','Age')

    #>

    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout/New-ScriptFromTemplate')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    #[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Making it pretty.')]
    [Alias('New-Script')]
    param (
        # The name of the new function.
        [Parameter(Mandatory, ParameterSetName = 'Named', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # The verb to use for the function name.
        [Parameter(Mandatory, ParameterSetName = 'VerbNoun', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Verb,

        # The noun to use for the function name.
        [Parameter(Mandatory, ParameterSetName = 'VerbNoun', Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Noun,

        # Synopsis of the new function.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Synopsis,

        # Description of the new function.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        # Optional alias for the new function.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Alias,

        # Name of the author of the script
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Author = (Get-CimInstance -ClassName Win32_UserAccount -Filter "Name = `'$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1])`'").FullName,

        # Parameter name(s) to include
        #[Parameter()]
        #[ValidateNotNullOrEmpty()]
        #[string[]]
        #$Parameter,

        # Path of the directory to save the new function in.
        [Parameter()]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]
        $Path,

        # Optionally skip name validation checks.
        [Parameter()]
        [switch]
        $SkipValidation
    )

    if ($PSBoundParameters.ContainsKey('Verb') -and -not $SkipValidation -and $Verb -notin (Get-Verb).Verb) {
        Write-Warning "`"$Verb`" is not an approved verb. Please run `"Get-Verb`" to see a list of approved verbs."
        break
    }

    if ($PSBoundParameters.ContainsKey('Verb') -and $PSBoundParameters.ContainsKey('Noun')) {
        $Name = "$Verb-$Noun"
    }

    if ($PSBoundParameters.ContainsKey('Name') -and -not $SkipValidation -and
        $Name -match '\w-\w' -and $Name.Split('-')[0] -notin (Get-Verb).Verb ) {
        Write-Warning "It looks like you are not using an approved verb: `"$($Name.Split('-')[0]).`" Please run `"Get-Verb`" to see a list of approved verbs."
    }

    # Set the script path and filename. Use current directory if no path specified.
    if (Test-Path -Path $Path -PathType Container) {
        $ScriptPath = [System.IO.Path]::Combine($Path, "$Name.ps1")
    } else {
        $ScriptPath = ".\$Name.ps1"
    }

    # Create the function builder string builder and function body string.
    $FunctionBuilder = [System.Text.StringBuilder]::New()
    $FunctionBody = (Get-Content -Path "$PSScriptRoot\ScriptTemplate.txt" -Raw)

    # Replace template placeholders with strings from parameter inputs.
    $FunctionBody = $FunctionBody -replace 'New-Function', $Name
    $FunctionBody = $FunctionBody -replace '__SYNOPSIS__', $Synopsis
    $FunctionBody = $FunctionBody -replace '__DESCRIPTION__', $Description
    $FunctionBody = $FunctionBody -replace '__DATE__', (Get-Date -Format 'yyyy-MM-dd')
    $FunctionBody = $FunctionBody -replace '__AUTHOR__', $Author
    # Set an alias for the new function if one is given in parameters.
    if ($PSBoundParameters.ContainsKey('Alias')) {
        $FunctionBody = $FunctionBody -replace '__ALIAS__', "[Alias(`'$Alias`')]"
    } else {
        $FunctionBody = $FunctionBody -replace '__ALIAS__', ''
    }

    # Create the new file.
    [void]$FunctionBuilder.Append($FunctionBody)
    $FunctionBuilder.ToString() | Out-File -FilePath $ScriptPath -Encoding utf8 -Force

} # end function New-ScriptFromTemplate
