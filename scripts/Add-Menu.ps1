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

    Push-Location #This part gets the json files and imports it
    cd $PSScriptRoot
    [string]$json = Get-Content "$filepath" -Raw
    $InputFile = ConvertFrom-Json -InputObject $json
    Pop-Location

    if ($InputFile.Menu[0].Backgroundcolor -ne ""){$host.UI.RawUI.BackgroundColor = $InputFile.Menu[0].Backgroundcolor}
    else {$host.UI.RawUI.BackgroundColor = $DefaultMenuColor}
    cls

    $ch = [console]::WindowHeight
    $cw = [console]::WindowWidth

    $CollectionHashArguments = @{} #Because there could be overlaps due to relative positioning, I add all the items to a hashtable first...
    #Then I check the coordinates, and increment duplicates until everything is unique
    foreach ($i in 0..($InputFile.Objects.Count-1)){
        $HashArguments = @{}
        
        #region Y allignment
        if ($InputFile.Objects[$i-1].yisrelative = "true"){ #Sets the Y coordinates. Can be relative or fixed. Warning: Relative menu items can overlap eachother
            $HashArguments.y = $ch/100*$InputFile.Objects[$i-1].y
        } elseif ($InputFile.Objects[$i-1].yisrelative = "false") {
            $HashArguments.y = $InputFile.Objects[$i-1].y
        } else{
            throw $IncorrectJSON
        }
        #endregion
        
        #region X allignment
        if ($InputFile.Objects[$i-1].XAlignment -eq "left"){
            if ($InputFile.Objects[$i-1].xisrelative = "true"){
                $HashArguments.x = $cw/100*$InputFile.Objects[$i-1].x
            } elseif ($InputFile.Objects[$i-1].xisrelative = "false") {
                $HashArguments.x = $InputFile.Objects[$i-1].x
            } else{
                throw $IncorrectJSON
            }
        } elseif ($InputFile.Objects[$i-1].XAlignment -eq "right"){
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
        elseif ($InputFile.Objects[$i-1].XAlignment -eq "center"){
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
            throw "X Alignment in JSON is incorrect: must be left, right or center"
        }
        if ($InputFile.Objects[$i-1].IsVariable){
            $HashArguments.text = $HashTable.($InputFile.Objects[$i-1].Text)
        } else {
            $HashArguments.text = $InputFile.Objects[$i-1].Text
        }
        if ($InputFile.Objects[$i-1].Backgroundcolor){ $HashArguments.Backgroundcolor = $InputFile.Objects[$i-1].Backgroundcolor }
        if ($InputFile.Objects[$i-1].Textcolor){ $HashArguments.Textcolor = $InputFile.Objects[$i-1].Textcolor }

        #Here I'm rounding to the nearest number. I'm doing it down here to keep the code above a little less cluttered than it already is.
        $HashArguments.x = [System.Math]::Round($HashArguments.x)
        $HashArguments.y = [System.Math]::Round($HashArguments.y)

        $CollectionHashArguments.Add($InputFile.Objects[$i-1].Index, $HashArguments)
        #Add-MenuItem @HashArguments
    }

    #This may take a little explaining. What I'm doing here is reading out every effective x Value and writing it to an array.
    #If the number already exists, it increments it in the hashtable and then adds it to the array.
    #This prevents menu items being overridden by overlapping items
    #$CollectionHashArguments = ($CollectionHashArguments.GetEnumerator() | Sort-Object Name)
    $CollectionHashArguments.GetType() | Out-File -FilePath D:\temp\test.txt -Append
    $CollectionHashArguments | Out-File -FilePath D:\temp\test.txt -Append
    $yCoordinates = @()
    foreach ($i in ($CollectionHashArguments.Keys | Sort-Object)) {
        while ( $yCoordinates.Contains($CollectionHashArguments.Item($i).item("y")) ) {
            $CollectionHashArguments.item($i).item("y") += 1
        }
        $yCoordinates += $CollectionHashArguments.Item($i).item("y")
        $PassValue = @{} #I could simplify the next 4 lines but I want to make it easily understandable
        $PassValue = $CollectionHashArguments.Item($i)
        $PassValue | Out-File -FilePath D:\temp\test.txt -Append
        Add-MenuItem @PassValue
    }
    $yCoordinates | Out-File -FilePath D:\temp\test.txt -Append
    return $InputFile
}