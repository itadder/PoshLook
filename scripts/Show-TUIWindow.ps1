function Show-TUIWindow {
    Param()
    gci "$PSScriptRoot\dll\TUI\" | select -ExpandProperty FullName | Import-Module -Force
    
    <#
    $a = [tuibase.window]::new()
    $a.Size = [tuibase.console.coordinates]::new(60,30)
    $a.Location = [tuibase.console.coordinates]::new(10,3)
    $a.Text = 'Hello World'
    $b = [tuibase.textpanel]::new()
    $b.Text = "Hello World 1"
    $b.Location = [tuibase.console.Coordinates]::New(1, 1)
    $b.Size = [tuibase.console.Coordinates]::New(57, 5)
    $a.AddControl($b)

    #>

    $MainMenu = [TuiBase.PopUpMenu]::new(
        'Main Menu',
        (
            [TuiBase.PopUpMenuItem[]]@(
                [TuiBase.PopUpMenuItem]::new("Controls",{gci | Out-GridView}),
                [TuiBase.PopUpMenuItem]::new("TextPanel",{Write-host 'Hello'}),
                [TuiBase.PopUpMenuItem]::new("Windows and Dialogs",{Write-host 'World'}),
                [TuiBase.PopUpMenuItem]::new("Exit",{$MainMenu.Close()})
            )
        )
    )



    $WindowRuntime = [TuiBase.WindowRuntime]
    $WindowRuntime::Initialize()
    $WindowRuntime::Run([Tui.TextConsole.ConsoleImpl]::new(), $MainMenu)
}