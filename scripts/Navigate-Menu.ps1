function NavigateMenu
{
    Param(
        [Parameter(Mandatory=$true)]
        $InputJSON
    )
    
    foreach ($i in 0..($InputJSON.Objects.Count-1)){
        if (!$InputJSON.Objects[$i-1].IsSelectable){
            $FirstIndex = $InputJSON.Objects[$i-1].Index
            break
        }
    }
    if (!$FirstIndex) {throw "Didn't find selectable Index!"}
    $Indexes = @{}
    foreach ($i in 0..($InputJSON.Objects.Count-1)){
        $Indexes.Add($InputJSON.Objects[$i-1].Index, $i-1)
    }
    while ($true)
    {
        
    }
}