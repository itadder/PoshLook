<#
.Synopsis
   Imports a JSON file that contains the layout for the menu
.DESCRIPTION
   Imports a JSON file that contains the layout for the Menu and calls Add-MenuItem for each object within the json file under "Objects".
   Look at example.json for formating of JSON files.
   It returns the imported JSON file so it can be processed by things like menu navigation and submenus.
.EXAMPLE
   Add-MenuItem -filepath example.json
   Draws a menu based on example.json
.EXAMPLE
   Add-Menu -filepath C:\example\customlayout\custommenu.json
   Draws a menu based on C:\example\customlayouy\custommenu.json
.LINK
   Github project: https://github.com/poshlook/PoshLook
#>
Function Add-Menu{
    param(
        #Filepath to the JSON File.
        [string]$filepath
    )

    #Variables
    $DefaultMenuColor = "DarkMagenta" #Our menus default background color
    #End Variables

    Push-Location
    cd $PSScriptRoot
    [string]$json = Get-Content "$filepath" -Raw
    $InputFile = ConvertFrom-Json -InputObject $json
    Pop-Location

    if ($InputFile.Menu[0].Backgroundcolor -ne ""){$host.UI.RawUI.BackgroundColor = $InputFile.Menu[0].Backgroundcolor}
    else {$host.UI.RawUI.BackgroundColor = $DefaultMenuColor}
    cls

    foreach ($i in 0..($InputFile.Objects.Count-1)){
        $HashArguments = @{text = $InputFile.Objects[$i-1].Text; x = $InputFile.Objects[$i-1].x; y = $InputFile.Objects[$i-1].y}
        if ($InputFile.Objects[$i-1].Backgroundcolor){ $HashArguments.Backgroundcolor = $InputFile.Objects[$i-1].Backgroundcolor }
        if ($InputFile.Objects[$i-1].Textcolor){ $HashArguments.Textcolor = $InputFile.Objects[$i-1].Textcolor }
        Add-MenuItem @HashArguments
    }
    return $InputFile
}