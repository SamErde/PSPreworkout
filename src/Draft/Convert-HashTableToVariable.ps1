function Convert-HashtableToVariable {
   [CmdletBinding(HelpUri = 'https://day3bits.com/PSPreworkout')]
   param ()
   foreach ($key in $_.Keys) { Set-Variable -Name $key -Value $_[$key] }
}
