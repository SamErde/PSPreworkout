function New-Credential {
    <#
    .SYNOPSIS
    Create a new secure credential.

    .DESCRIPTION
    Create a new secure credential to use in other functions.

    .EXAMPLE
    $Credential = New-Credential
    #>
    [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'OK')]
    param ()
    Write-Output 'Create a Credential'
    $User = Read-Host -Prompt 'User'
    $Password = Read-Host "Password for user $User" -AsSecureString
    $Credential = [System.Management.Automation.PSCredential]::New($User, $Password)
    $Credential
} # end function New-Credential
