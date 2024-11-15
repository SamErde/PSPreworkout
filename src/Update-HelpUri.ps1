$Files = Get-ChildItem -Path PSPreworkout -Filter *.ps1 -Recurse
foreach ($file in $Files) {
    $BareUrl = 'HelpUri = ''https://day3bits.com/PSPreworkout'''
    $FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $NewUrl = $($BareUrl.Replace("PSPreworkout'", 'PSPreworkout') + "/$FunctionName'")
    $FileContents = Get-Content -Path $file.FullName
    $NewFileContents = $FileContents.Replace($BareUrl, $NewUrl)
    $NewFileContents | Set-Content -Path $file.FullName -Force
}
