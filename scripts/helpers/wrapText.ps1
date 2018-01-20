function wrapText( $text, $width=80 )
{
    $words = $text -split "\s+"
    $col = 0
    (-join$(
    foreach ( $word in $words ){
        $col += $word.Length + 1
        if ( $col -gt $width ){
            "`r`n"
            $col = $word.Length + 1
        }
        "$word "
    }
    )) -split "`r`n"
}