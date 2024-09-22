function Convert-HashtableToVariable {
   [CmdletBinding()]
   param ()
   foreach ($key in $_.Keys) { Set-Variable -Name $key -Value $_[$key] }
} 
