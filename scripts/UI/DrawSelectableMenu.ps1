param(
    #The hashtable of the json file. Ther difference between the hashtable and the json 
    #file is that here everything is already written out in the effective coordinates
    [hashtable]$json,
    
    #The Index selected by the user
    #[Parameter(Mandatory=$false)]
    [int32]$SelectedIndex
)

$json1 = $json.clone()
foreach ($i in ($json1.Keys | Sort-Object)) {
    $PassValue = @{}
    $PassValue = $json1.Item($i).clone()
    if ($i -eq $SelectedIndex) {
        $PassValue.Item("backgroundcolor") = "Black"
        $PassValue.Item("textcolor") = "White"
    }
    #$PassValue | Out-File -FilePath D:\temp\test.txt -Append
    .\Add-MenuItem.ps1 @PassValue
}