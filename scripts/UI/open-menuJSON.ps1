<#
   Imports a JSON file that contains the layout for the Menu and calls Add-MenuItem for each object within the json file under "Objects".
   Look at example.json for formating of JSON files.
   This can take a mix of static positioned items and dynamic positioned items.
   It returns the imported JSON file so it can be processed by things like menu navigation and submenus.
#>
param(
    #Filepath to the JSON File.
    $Inputjson,
    
    #HashTable input if you want have dynamic text in the JSON
    [Parameter(Mandatory=$false)]
    $HashTable
)

#Variables
$DefaultMenuColor = "DarkMagenta" #Our menus default background color
$IncorrectJSON = "relativity in JSON is incorrect, must be true or false."
#End Variables

if ($Inputjson.Menu[0].Backgroundcolor -ne ""){$host.UI.RawUI.BackgroundColor = $Inputjson.Menu[0].Backgroundcolor}
else {$host.UI.RawUI.BackgroundColor = $DefaultMenuColor}

$ch = [console]::WindowHeight
$cw = [console]::WindowWidth

$CollectionHashArguments = @{} #Because there could be overlaps due to relative positioning, I add all the items to a hashtable first...
#Then I check the coordinates, and increment duplicates until everything is unique
foreach ($i in 0..($Inputjson.Objects.Count-1)){
    $HashArguments = @{}

    #region Y allignment
    if ($Inputjson.Objects[$i-1].yisrelative){ #Sets the Y coordinates. Can be relative or fixed. Warning: Relative menu items can overlap eachother
        $HashArguments.y = $ch/100*$Inputjson.Objects[$i-1].y
    } elseif (!$Inputjson.Objects[$i-1].yisrelative) {
        $HashArguments.y = $Inputjson.Objects[$i-1].y
    } else{
        throw $IncorrectJSON
    }
    #endregion
    
    $HashArguments.OnSelection = $Inputjson.Objects[$i-1].OnSelection

    #region X allignment
    if ($Inputjson.Objects[$i-1].XAlignment -eq "left"){
        if ($Inputjson.Objects[$i-1].xisrelative){
            $HashArguments.x = $cw/100*$Inputjson.Objects[$i-1].x
        } elseif (!$Inputjson.Objects[$i-1].xisrelative) {
            $HashArguments.x = $Inputjson.Objects[$i-1].x
        } else {
            throw $IncorrectJSON
        }
    } elseif ($Inputjson.Objects[$i-1].XAlignment -eq "right"){
        if ($Inputjson.Objects[$i-1].xisrelative){
            if ($Inputjson.Objects[$i-1].IsVariable){
                $HashArguments.x = ($cw/100*$Inputjson.Objects[$i-1].x)-($HashTable.($Inputjson.Objects[$i-1].Text)).Length
            } else {
                $HashArguments.x = ($cw/100*$Inputjson.Objects[$i-1].x)-$Inputjson.Objects[$i-1].Text.Length
            }
        } elseif (!$Inputjson.Objects[$i-1].yisrelative) {
            if ($Inputjson.Objects[$i-1].IsVariable){
                $HashArguments.x = $Inputjson.Objects[$i-1].x-($HashTable.($Inputjson.Objects[$i-1].Text)).Length
            } else {
                $HashArguments.x = $Inputjson.Objects[$i-1].x-$Inputjson.Objects[$i-1].Text.Length
            }
        } else {
            throw $IncorrectJSON
        }
    }
    elseif ($Inputjson.Objects[$i-1].XAlignment -eq "center"){
        if ($Inputjson.Objects[$i-1].xisrelative){
            if ($Inputjson.Objects[$i-1].IsVariable){
                $HashArguments.x = ($cw/100*$Inputjson.Objects[$i-1].x)-(($HashTable.($Inputjson.Objects[$i-1].Text)).Length/2)
            } else {
                $HashArguments.x = ($cw/100*$Inputjson.Objects[$i-1].x)-(($Inputjson.Objects[$i-1].Text.Length)/2)
            }
        } elseif (!$Inputjson.Objects[$i-1].xisrelative){
            if ($Inputjson.Objects[$i-1].IsVariable){
                $HashArguments.x = $Inputjson.Objects[$i-1].x-(($HashTable.($Inputjson.Objects[$i-1].Text)).Length/2)
            } else {
                $HashArguments.x = $Inputjson.Objects[$i-1].x-($Inputjson.Objects[$i-1].Text.Length)/2
            }
        } else {
            throw $IncorrectJSON
        }
    } else {
        throw "X Alignment in JSON is incorrect: must be left, right or center"
    }
    if ($Inputjson.Objects[$i-1].IsVariable){
        $HashArguments.text = $HashTable.($Inputjson.Objects[$i-1].Text)
    } else {
        $HashArguments.text = $Inputjson.Objects[$i-1].Text
    }
    if ($Inputjson.Objects[$i-1].Backgroundcolor){ $HashArguments.Backgroundcolor = $Inputjson.Objects[$i-1].Backgroundcolor }
    if ($Inputjson.Objects[$i-1].Textcolor){ $HashArguments.Textcolor = $Inputjson.Objects[$i-1].Textcolor }

    #Here I'm rounding to the nearest number. I'm doing it down here to keep the code above a little less cluttered than it already is.
    $HashArguments.x = [System.Math]::Round($HashArguments.x)
    $HashArguments.y = [System.Math]::Round($HashArguments.y)

    $CollectionHashArguments.Add($Inputjson.Objects[$i-1].Index, $HashArguments)
}

#This may take a little explaining. What I'm doing here is reading out every effective x Value and writing it to an array.
#If the number already exists, it increments it in the hashtable and then adds it to the array.
#This prevents menu items being overridden by overlapping items
#$CollectionHashArguments = ($CollectionHashArguments.GetEnumerator() | Sort-Object Name)
$yCoordinates = @()
foreach ($i in ($CollectionHashArguments.Keys | Sort-Object)) {
    while ( $yCoordinates.Contains($CollectionHashArguments.Item($i).item("y")) ) {
        $CollectionHashArguments.item($i).item("y") += 1
    }
    $yCoordinates += $CollectionHashArguments.Item($i).item("y")
    #$PassValue = @{} #I could simplify the next 4 lines but I want to make it easily understandable
    #$PassValue = $CollectionHashArguments.Item($i)
    #Add-MenuItem @PassValue
}
return $CollectionHashArguments