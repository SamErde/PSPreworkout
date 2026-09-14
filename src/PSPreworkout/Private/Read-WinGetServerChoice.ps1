function Read-WinGetServerChoice {
    <#
    .SYNOPSIS
    Prompts before updating packages on Windows Server.

    .DESCRIPTION
    Shows a host choice prompt that defaults to declining WinGet package updates.

    .OUTPUTS
    System.Int32
    #>

    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [object]$HostUserInterface = $Host.UI
    )

    $Options = [System.Management.Automation.Host.ChoiceDescription[]]@(
        [System.Management.Automation.Host.ChoiceDescription]::new('&Yes', 'Continue with WinGet package updates.')
        [System.Management.Automation.Host.ChoiceDescription]::new('&No', 'Skip WinGet package updates.')
    )

    return $HostUserInterface.PromptForChoice(
        'Windows Server OS Found',
        "Do you want to run 'winget upgrade' on your server?",
        $Options,
        1
    )
}
