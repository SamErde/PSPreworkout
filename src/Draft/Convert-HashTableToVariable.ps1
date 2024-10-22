function Convert-HashtableToVariable {
   [CmdletBinding(HelpUri = 'https://raw.githubusercontent.com/SamErde/PSPreworkout/main/src/Help/')]
   param ()
   foreach ($key in $_.Keys) { Set-Variable -Name $key -Value $_[$key] }
}
