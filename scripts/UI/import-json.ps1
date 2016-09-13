param(
    #The Filepath to the json to be imported
    [string]$filepath
)

Push-Location #This part gets the json files and imports it
cd $PSScriptRoot
[string]$json = Get-Content "$filepath" -Raw
$InputFile = ConvertFrom-Json -InputObject $json
Pop-Location

return $InputFile