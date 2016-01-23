Function Add-Menu{
    param(
        [string]$filepath
    )
    
    cls
    Push-Location
    cd $PSScriptRoot
    [string]$json = Get-Content "MainMenu.design" -Raw
    $InputFile = ConvertFrom-Json -InputObject $json
    Pop-Location

    foreach ($i in 0..($InputFile.Objects.Count-1)){
        $HashArguments = @{text = $InputFile.Objects[$i-1].Text; x = $InputFile.Objects[$i-1].x; y = $InputFile.Objects[$i-1].y}
        if ($InputFile.Objects[$i-1].Backgroundcolor){ $HashArguments.Backgroundcolor = $InputFile.Objects[$i-1].Backgroundcolor }
        if ($InputFile.Objects[$i-1].Textcolor){ $HashArguments.Textcolor = $InputFile.Objects[$i-1].Textcolor }
        Add-MenuItem @HashArguments
    }
    return $InputFile
}