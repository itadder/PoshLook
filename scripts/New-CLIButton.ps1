function New-CLIButton {
    Param(
        [Parameter(Mandatory=$true)]
        $Parent,
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [Parameter()]
        $Width = 25,
        [Parameter()]
        $Height = 3,
        [Parameter()]
        $TopPadding = 2,
        [Parameter()]
        $LeftPadding = 2,
        [Parameter()]
        $ClickAction
        #[Parameter()]
        #[ValidateSet('None','Thin','Thick','Block')][string]$BorderStyle = 'Thin',
        #[Parameter()]
        #[switch]$Visible
    )
    
    $ThisButton = [CLRCLI.Widgets.Button]::new($Parent)
    $ThisButton.Text = $Text
    $ThisButton.Top = $TopPadding
    $ThisButton.Left = $LeftPadding
    $ThisButton.Width = $Width
    $ThisButton.Height = $Height
    $ThisButton.Add_Clicked($ClickAction)

    $ThisButton
}


