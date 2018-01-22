function Show-TUIWindow {
    Param()
    gci "$PSScriptRoot\dll\TUI\" | select -ExpandProperty FullName | Import-Module -Force

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