param(
    #The hashtable of the json file. Ther difference between the hashtable and the json 
    #file is that here everything is already written out in the effective coordinates
    [hashtable]$menu,
    
    #The Index selected by the user
    [Array]$Indexes,

    #The default Index
    $DefaultIndex
)

Clear-Host
Set-Variable -Name menu
#For debug purposes I loop through every sub-hash table in the hashtable
$passablemenu = $menu.Clone() #GAAAAAAAAH THIS DOES NOT CLONE THE UNDERLYING HASHTABLES
.\DrawSelectableMenu.ps1 -json $passablemenu -SelectedIndex $DefaultIndex #Draws the menu with the default selected item
$placeInArray = $Indexes.IndexOf($DefaultIndex) #Gets place where the default index is
while (!$PressedAction) {
    $KeyPressed = [Console]::ReadKey() #This gets the key that the user pressed
    if (($KeyPressed.Key -eq "Tab" -and $KeyPressed.Modifiers -ne "Shift")`
        -or ($KeyPressed.Key -eq "DownArrow")) #If you press down or tab...
    {
        $placeInArray++
        if ($placeInArray -gt $Indexes.Count){ $placeInArray = 0 } #loop around
        Clear-Host
        $passablemenu = $menu.Clone()
        .\DrawSelectableMenu.ps1 -json $passablemenu -SelectedIndex $Indexes[$placeInArray] #Draw again
    }
    elseif (($KeyPressed.Key -eq "Tab" -and $KeyPressed.Modifiers -eq "Shift")`
        -or ($KeyPressed.Key -eq "UpArrow")) #If you press up or shift-tab...
    {
        $placeInArray--
        if ($placeInArray -eq -1){ $placeInArray = ($Indexes.Count-1) } #loop around
        Clear-Host
        $passablemenu = $menu.Clone()
        .\DrawSelectableMenu.ps1 -json $passablemenu -SelectedIndex $Indexes[$placeInArray] #Draw again
    }
    elseif ($KeyPressed.Key -eq "Enter") { #if enter is pressed it will return the command stored in the JSON file 
        Clear-Host
        $passablemenu.clear()
        return $menu.Item($Indexes[$placeInArray]).Item("OnSelection")
    }
    elseif ($KeyPressed.Key -eq "Escape"){ #If esc is hit it should tell the main .ps1 that
        Clear-Host
        $passablemenu.clear()
        return "Escape"
    }
}