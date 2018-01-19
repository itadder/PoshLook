function New-CLILabel {
    Param(
        [Parameter(Mandatory=$true)]
        $Parent,
        [Parameter(Mandatory=$true)]
        [string]$Text,
        #[Parameter()]
        #$Width = 60,
        #[Parameter()]
        #$Height = 32,
        #[Parameter()]
        $TopPadding = 2,
        [Parameter()]
        $LeftPadding = 2
        #[Parameter()]
        #[ValidateSet('None','Thin','Thick','Block')][string]$BorderStyle = 'Thin',
        #[Parameter()]
        #[switch]$Visible
    )

    $ThisLabel = [CLRCLI.Widgets.Label]::new($Parent)
    $ThisLabel.Text = $Text
    $ThisLabel.Top = $TopPadding
    $ThisLabel.Left = $LeftPadding

    $ThisLabel
}