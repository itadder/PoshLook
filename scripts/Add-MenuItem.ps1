function Add-MenuItem{
    param(
        [string]$text,
        [int]$x,
        [int]$y,
        [string]$backgroundcolor="DarkMagenta",
        [string]$textcolor="DarkYellow"
    )
    $position=$host.ui.rawui.cursorposition
    $position.x = $x
    $position.y = $y
    $host.ui.rawui.cursorposition=$position
    Write-Host -NoNewline $text -BackgroundColor $Backgroundcolor -ForegroundColor $textcolor
}