function Enter-PoshLookSession {
    [cmdletbinding()]
    Param(
        
    )
    #dll loading
    Import-Module "$PSScriptRoot\dll\CLRCLI-Master\CLRCLI-master\CLRCLI\bin\Debug\CLRCLI.dll"
    #create root base
    $Root = [CLRCLI.Widgets.RootWindow]::new()
    #first Dialog box
    $Dialog = [CLRCLI.Widgets.Dialog]::new($Root)

    $Dialog.Text = "PoshLook [Mail,Contacts,Calendar,Tasks]"
    $Dialog.Width = 60
    $Dialog.Height = 32
    $Dialog.Top = 4
    $Dialog.Left = 4
    $Dialog.Border = [CLRCLI.BorderStyle]::Thick

    # adding labels
    $Label = [CLRCLI.Widgets.Label]::new($Dialog)
    $Label.Text = "Posh Look E-mail Folders"
    $Label.Top = 2
    $Label.Left = 2

    $Button = [CLRCLI.Widgets.Button]::new($Dialog)
    $Button.Text = "Show-MailFolder"
    $Button.Top = 4
    $Button.Left = 6
    $Button.Width = 25

    $Button2 = [CLRCLI.Widgets.Button]::new($Dialog)
    $Button2.Text = "View-Inbox-Folder"
    $Button2.Top = 4
    $Button2.Left = 34
    $Button2.Width = 25

    $list = [CLRCLI.Widgets.ListBox]::new($Dialog)
    $list.top = 10
    $list.Left = 4
    $list.Width = 32
    $list.height = 6
    $list.Border = [CLRCLI.BorderStyle]::Thin

    $selection = $list.SelectedItem
    #$list.Keypress() -eq $true
    #[system.consolekeyinfo]::new('A',[System.ConsoleKey]::A,$false,$false,$false)
    $selection

    #Second Dialog box hidden from first

    $Dialog2 = [CLRCLI.Widgets.Dialog]::new($Root)
    $Dialog2.Text = $selection
    $Dialog2.Text = "view Inbox" 
    $Dialog2.Width = 150
    $Dialog2.Height = 32 
    $Dialog2.Top = 6
    $Dialog2.Left = 6
    $Dialog2.Border = [CLRCLI.BorderStyle]::Thick
    $Dialog2.Visible = $false

    $list2 = [CLRCLI.Widgets.ListBox]::new($Dialog2)
    $list2.top = 10
    $list2.Left = 4
    $list2.Width = 100
    $list2.height = 6
    $list2.Border = [CLRCLI.BorderStyle]::Thin

    $selection2 = $list2.SelectedItem
    #$list2.Keypress() -eq $true
    $selection2

    # Add buttons

    # $Button3 = [CLRCLI.Widgets.Button]::new($Dialog2)
    # $Button3.Text = "Bye!"
    # $Button3.Width = 8
    # $Button3.Height = 3
    # $Button3.Top = 1
    # $Button3.Left = 1

    $Button4 = [CLRCLI.Widgets.Button]::new($Dialog2)
    $Button4.Text = "Exit"
    $Button4.Width = 8
    $Button4.Height = 3
    $Button4.Top = 30 
    $Button4.Left = 5 



    # Based on events button do something
    $Button4.Add_Clicked({$root.Detach()}) 
    #$Button3.Add_Clicked( {$Dialog2.Hide(); $Dialog.Show()})
    #$Button2.Add_Clicked( {$Dialog.Hide(); $Dialog2.Show()})
        #$inbox = Get-EWSFolder -Path $selection  |  Get-EWSItem -Filter * 
        #$listadd2 = $inbox | ForEach-Object {$list2.items.add($_)}
    $Button2.Add_Clicked({
        #$List2Item = [system.collections.arraylist]::new()
        $Dialog.Hide();
        $Dialog2.Show();
        (Get-EWSFolder -Path 'Inbox').FindItems(50).Subject | %{
            $list2.Items.Add($_)
        }
    })
    $Button.Add_Clicked( { 
        $listitem = [system.collections.arraylist]::new()
        (Get-EWSFolder -Path MsgFolderRoot).FindFolders([int]::MaxValue) | ?{$_.FolderClass -eq 'IPF.Note'} | %{
            [void]$listitem.Add($_.DisplayName)
            if ($_.ChildFolderCount){
                [void]$listitem.Add("($($_.ChildFolderCount))")
            }
            $list.items.add($listitem -join ' ')
            $listitem.Clear()
        }
    } )
    #$Button.Add_Clicked( { Get-Process | select -ExpandProperty ProcessName | foreach { $list.items.add($_) }  })
    # run cli gui
    $Root.Run()
}