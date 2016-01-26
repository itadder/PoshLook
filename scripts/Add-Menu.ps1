<#
.Synopsis
   Imports a JSON file that contains the layout for a dynamic and fix menu
.DESCRIPTION
   Imports a JSON file that contains the layout for the Menu and calls Add-MenuItem for each object within the json file under "Objects".
   Look at example.json for formating of JSON files.
   This can take a mix of static positioned items and dynamic positioned items.
   It returns the imported JSON file so it can be processed by things like menu navigation and submenus.
.EXAMPLE
   Add-Menu -filepath dynamicexample.json
   Draws a menu based on example.json
.EXAMPLE
   Add-Menu -filepath C:\example\customlayout\customdynamicmenu.json
   Draws a menu based on C:\example\customlayouy\customdynamicmenu.json
.LINK
   Github project: https://github.com/poshlook/PoshLook
#>
Function Add-Menu{
    param(
        #Filepath to the JSON File.
        [string]$filepath,
        
        #HashTable input if you want have dynamic text in the JSON
        [Parameter(Mandatory=$false)]
        $HashTable
    )
    
    #Variables
    $DefaultMenuColor = "DarkMagenta" #Our menus default background color
    $IncorrectJSON = "relativity in JSON is incorrect, must be true or false."
    #End Variables

    Push-Location
    cd $PSScriptRoot
    [string]$json = Get-Content "$filepath" -Raw
    $InputFile = ConvertFrom-Json -InputObject $json
    Pop-Location

    if ($InputFile.Menu[0].Backgroundcolor -ne ""){$host.UI.RawUI.BackgroundColor = $InputFile.Menu[0].Backgroundcolor}
    else {$host.UI.RawUI.BackgroundColor = $DefaultMenuColor}
    cls

    $ch = [console]::WindowHeight
    $cw = [console]::WindowWidth

    foreach ($i in 0..($InputFile.Objects.Count-1)){
        $HashArguments = @{}
        
        if ($InputFile.Objects[$i-1].yisrelative = "true"){
            $HashArguments.y = $ch/100*$InputFile.Objects[$i-1].y
        } elseif ($InputFile.Objects[$i-1].yisrelative = "false") {
            $HashArguments.y = $InputFile.Objects[$i-1].y
        } else{
            throw $IncorrectJSON
        }
        
        if ($InputFile.Objects[$i-1].Alignment -eq "left"){
            if ($InputFile.Objects[$i-1].xisrelative = "true"){
                $HashArguments.x = $cw/100*$InputFile.Objects[$i-1].x
            } elseif ($InputFile.Objects[$i-1].xisrelative = "false") {
                $HashArguments.x = $InputFile.Objects[$i-1].x
            } else{
                throw $IncorrectJSON
            }
        } elseif ($InputFile.Objects[$i-1].Alignment -eq "right"){
            if ($InputFile.Objects[$i-1].xisrelative = "true"){
                if ($InputFile.Objects[$i-1].IsVariable){
                    $HashArguments.x = ($cw/100*$InputFile.Objects[$i-1].x)-($HashTable.($InputFile.Objects[$i-1].Text)).Length
                } else {
                    $HashArguments.x = ($cw/100*$InputFile.Objects[$i-1].x)-$InputFile.Objects[$i-1].Text.Length
                }
            } elseif ($InputFile.Objects[$i-1].yisrelative = "false") {
                if ($InputFile.Objects[$i-1].IsVariable){
                    $HashArguments.x = $InputFile.Objects[$i-1].x-($HashTable.($InputFile.Objects[$i-1].Text)).Length
                } else {
                    $HashArguments.x = $InputFile.Objects[$i-1].x-$InputFile.Objects[$i-1].Text.Length
                }
            } else {
                throw $IncorrectJSON
            }
        }
        elseif ($InputFile.Objects[$i-1].Alignment -eq "center"){
            if ($InputFile.Objects[$i-1].xisrelative = "true"){
                if ($InputFile.Objects[$i-1].IsVariable){
                    $HashArguments.x = ($cw/100*$InputFile.Objects[$i-1].x)-(($HashTable.($InputFile.Objects[$i-1].Text)).Length/2)
                } else {
                    $HashArguments.x = ($cw/100*$InputFile.Objects[$i-1].x)-(($InputFile.Objects[$i-1].Text.Length)/2)
                }
            } elseif ($InputFile.Objects[$i-1].xisrelative = "false"){
                if ($InputFile.Objects[$i-1].IsVariable){
                    $HashArguments.x = $InputFile.Objects[$i-1].x-(($HashTable.($InputFile.Objects[$i-1].Text)).Length/2)
                } else {
                    $HashArguments.x = $InputFile.Objects[$i-1].x-($InputFile.Objects[$i-1].Text.Length)/2
                }
            } else {
                throw $IncorrectJSON
            }
        } else {
            throw "Alignment in JSON is incorrect: must be left, right or center"
        }
        if ($InputFile.Objects[$i-1].IsVariable){
            $HashArguments.text = $HashTable.($InputFile.Objects[$i-1].Text)
        } else {
            $HashArguments.text = $InputFile.Objects[$i-1].Text
        }
        if ($InputFile.Objects[$i-1].Backgroundcolor){ $HashArguments.Backgroundcolor = $InputFile.Objects[$i-1].Backgroundcolor }
        if ($InputFile.Objects[$i-1].Textcolor){ $HashArguments.Textcolor = $InputFile.Objects[$i-1].Textcolor }
        Add-MenuItem @HashArguments
    }
    return $InputFile
}