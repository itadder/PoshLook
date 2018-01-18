#The main menu of the program

Push-Location
cd $PSScriptRoot
$rawjson = .\import-json.ps1 -Filepath "./menus/mainmenu.json"
$MainMenuJSON = .\Open-MenuJSON.ps1 -inputjson $rawjson
$SelectableIndexes = .\Get-SelectableMenuIndexes.ps1 -InputJSON $rawjson
[int32]$DefaultIndex = ($SelectableIndexes | measure -Minimum).Minimum
$nextCommand = .\NavigateMenu.ps1 -menu $MainMenuJSON -Indexes $SelectableIndexes -DefaultIndex $DefaultIndex
return $nextCommand

Pop-Location