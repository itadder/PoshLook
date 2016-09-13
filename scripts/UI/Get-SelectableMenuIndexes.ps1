<#
   Imports a JSON file that contains the layout for the Menu and gets the index of the selectable items.
   The return values are then passed back so they can be used for other things.
#>
Param(
    [Parameter(Mandatory=$true)]
    $InputJSON
)
    
$Indexes = @()
foreach ($i in 0..($InputJSON.Objects.Count-1)){
    if ($InputJSON.Objects[$i-1].IsSelectable){
        $Indexes += ($InputJSON.Objects[$i-1].Index)
    }
}
if ($Indexes.Count -eq 0) {throw "Didn't find selectable Index!"}
$Indexes = ($Indexes | sort)
return $indexes
