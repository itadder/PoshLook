function New-CLIList {
    Param(
        [Parameter(Mandatory=$true)]
        $Parent,
        [Parameter()]
        [string]$Text,
        [Parameter()]
        $Width = 32,
        [Parameter()]
        $Height = 6,
        [Parameter()]
        $TopPadding = 10,
        [Parameter()]
        $LeftPadding = 4,
        [Parameter()]
        [ValidateSet('None','Thin','Thick','Block')][string]$BorderStyle = 'Thin',
        [Parameter()]
        [scriptblock]$ClickAction
        
    )
    
    $ThisList = [CLRCLI.Widgets.ListBox]::new($Parent)
    $ThisList.top = $TopPadding
    $ThisList.Left = $LeftPadding
    $ThisList.Width = $Width
    $ThisList.height = $Height
    $ThisList.Border = [CLRCLI.BorderStyle]::$BorderStyle
    $ThisList.Add_Clicked($ClickAction)

    $ThisList
}


