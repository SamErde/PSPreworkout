function Convert-HashtableToVariable {
   [CmdletBinding()]
   foreach ($key in $_.Keys) { Set-Variable -Name $key -Value $_[$key] }
} 
