<#
.Synopsis
   Adds text, optionaly with color to the x and y positions of the interface.
.DESCRIPTION
   Adds text, optionaly with color to the x and y positions of the interface.
.EXAMPLE
   Add-MenuItem -text "You have new mail." -x 0 -y 10 -backgroundcolor "Blue"
   Adds "You have new mail." a x-coordinate 0 and y coordinate 10 with the backgroundcolor of the letters being blue.
.EXAMPLE
   Add-MenuItem -text "[Contacts]" -x 6 -y 20 -textcolor "green"
   Adds "[Contacts]" a x-coordinate 6 and y coordinate 20 with the text color of the letters being green.
.LINK
   Github project: https://github.com/poshlook/PoshLook
#>
function Add-MenuItem{
    param(
        #Input text that will be displayed
        [string]$text,

         #x coordinate
        [int]$x,

         #y coordinate
        [int]$y,

        #Backgroundcolor (Of the text, not the screen)
        [string]$backgroundcolor="DarkMagenta",

        #Text color
        [string]$textcolor="DarkYellow"
    )
    $position=$host.ui.rawui.cursorposition
    $position.x = $x
    $position.y = $y
    $host.ui.rawui.cursorposition=$position
    Write-Host -NoNewline $text -BackgroundColor $Backgroundcolor -ForegroundColor $textcolor
}