#import-module "C:\Program Files\WindowsPowerShell\Modules\PoshLook\scripts\dll\CLRCLI-Master\CLRCLI-master\CLRCLI\bin\Debug\CLRCLI.dll"

#Valid border styles - Make Parameter validation dynamic later
# [CLRCLI.BorderStyle].DeclaredMembers | select -ExpandProperty Name | ?{$_ -notmatch '__'}

function New-CLIDialog {
    Param(
        [Parameter(Mandatory=$true)]
        $Parent,
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [Parameter()]
        $Width = 60,
        [Parameter()]
        $Height = 32,
        [Parameter()]
        $TopPadding = 4,
        [Parameter()]
        $LeftPadding = 4,
        [Parameter()]
        [ValidateSet('None','Thin','Thick','Block')][string]$BorderStyle = 'Thin',
        [Parameter()]
        [switch]$Visible
    )

    $ThisDialog = [CLRCLI.Widgets.Dialog]::new($RootWindow)

    $ThisDialog.Text = $Text
    $ThisDialog.Width = $Width
    $ThisDialog.Height = $Height
    $ThisDialog.Top = $TopPadding
    $ThisDialog.Left = $LeftPadding
    $ThisDialog.Border = [CLRCLI.BorderStyle]::$BorderStyle
    $ThisDialog.Visible = [bool]$Visible
    
    $ThisDialog
}