function Enter-PoshLookSession {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
            [string]$Mailbox,
        [Parameter()]
            $ServiceURL,
        [Parameter()]
            [ValidateSet(
                'Exchange2007_SP1',
                'Exchange2010',
                'Exchange2010_SP1',
                'Exchange2010_SP2',
                'Exchange2013',
                'Exchange2013_SP1'
            )][string]$Version,
        [Parameter()]
            [switch]$AllowRedirect,
        [Parameter()]
            [pscredential]$Credential
    )
    if (-not (Get-EWSService -InformationAction Stop)) {
        $SelectedParams = $PSBoundParameters
        Write-Verbose -Message 'Connecting to EWS Service'
        Connect-EWSService @SelectedParams
    }

    #dll loading
    #Import-Module "$PSScriptRoot\dll\CLRCLI-Master\CLRCLI-master\CLRCLI\bin\Debug\CLRCLI.dll"
   
    #create root base
    $RootWindow = [CLRCLI.Widgets.RootWindow]::new()
    
    #Define Dialog boxes
    $Dialogs = @(
        @{
            Name = 'FolderSelect'
            Config = @{
                Parent = $RootWindow
                Text = "PoshLook [Mail,Contacts,Calendar,Tasks]"
                Visible = $true
            }
            Dialog = $null
            Labels = @(
                @{
                    Name = 'Label1'
                    Config = @{
                        Text = "Posh Look E-mail Folders"
                        TopPadding = 2
                        LeftPadding = 2
                    }
                    Label = $null
                }
            )
            Lists = @(
                @{
                    Name = 'Folders'
                    Config = @{
                        TopPadding = 10
                        LeftPadding = 4
                        Width = 32
                        Height = 6
                        Border = 'Thin'
                        ClickAction = {
                            $Dialogs[0].Dialog.Hide();
                            $Dialogs[1].Dialog.Show();
                            $selection = $Dialogs[0].Lists[0].List.SelectedItem
                            $script:emails = (Get-EWSFolder -Path "MsgFolderRoot\$selection").FindItems(156)
                            $script:emails.Subject | %{
                                $Dialogs[1].Lists[0].List.Items.Add($_)
                            }
                        }
                    }
                    List = $null
                }
            )
            Buttons = @(
                @{
                    Name = 'ShowMail'
                    Config = @{
                        Text = 'Show-MailFolder'
                        Width = 25
                        TopPadding = 4
                        LeftPadding = 6
                        ClickAction = { 
                            $listitem = [system.collections.arraylist]::new()
                            (Get-EWSFolder -Path MsgFolderRoot).FindFolders([int]::MaxValue) | ?{$_.FolderClass -eq 'IPF.Note'} | %{
                                [void]$listitem.Add($_.DisplayName)
                                <#
                                if ($_.ChildFolderCount){
                                    [void]$listitem.Add("($($_.ChildFolderCount))")
                                }
                                #>
                                $Dialogs[0].Lists[0].List.items.add($listitem -join ' ')
                                $Dialogs[0].Lists[0].List.SetFocus()
                                $listitem.Clear()
                            }
                        }
                    }
                    Button = $null
                }
            )
        },
        @{
            Name = 'FolderView'
            Config = @{
                Parent = $RootWindow
                #Text = $selection
                Text = "view Inbox"
                Width = 150
                Height = 32
                TopPadding = 6
                LeftPadding = 6
                BorderStyle = 'Thick'
            }
            Dialog = $null
            Labels = @()
            Lists = @(
                @{
                    Name = 'Emails'
                    Config = @{
                        TopPadding = 10
                        LeftPadding = 4
                        Width = 100
                        height = 6
                        Border = 'Thin'
                        ClickAction = {
                            $Dialogs[1].Lists[1].List.Items.Clear()
                            $selection = $Dialogs[1].Lists[0].List.SelectedItem
                            $SelectedEmail = $script:emails | ?{$_.Subject -eq $selection}
                            $SelectedEmailBody = ((( Get-EWSMessage -id ($SelectedEmail.id | select -first 1) | select -ExpandProperty BodyText ) -replace '<[^>]+>','') -split "`r`n") | %{if($_){wrapText -text $_}else{$_}}

                            $ErrorActionPreference = "SilentlyContinue"
                            $SelectedEmailBody | select -first 155 | %{
                                $Dialogs[1].Lists[1].List.Items.Add($_)
                            }
                            $ErrorActionPreference = "Continue"
                        }
                    }
                    List = $null
                },
                @{
                    Name = 'Email Preview'
                    Config = @{
                        TopPadding = 20
                        LeftPadding = 10
                        Width = 100
                        height = 8
                        Border = 'Thin'
                    }
                    List = $null
                }
            )
            Buttons = @(
                @{
                    Name = 'Exit'
                    Config = @{
                        Text = "Exit"
                        Width = 8
                        Height = 3
                        TopPadding = 30
                        LeftPadding = 5
                        ClickAction = {$RootWindow.Detach()}
                    }
                    Button = $null
                }
            )
        }
    )

    #Executing configuration
    $Dialogs | %{
        $ThisConfig = $_.Config
        $_.Dialog = New-CLIDialog @ThisConfig
        $ThisDialog = $_.Dialog
        $_.Labels | %{
            $ThisLabel = $_.Config
            $_.Label = New-CLILabel @ThisLabel -Parent $ThisDialog
        }
        $_.Lists | %{
            $ThisList = $_.Config
            $_.List = New-CLIList @ThisList -Parent $ThisDialog
        }
        $_.Buttons | %{
            $ThisButton = $_.Config
            $_.Button = New-CLIButton @ThisButton -Parent $ThisDialog
        }
    }
    

    #$selection = $list.SelectedItem
    #$selection2 = $list2.SelectedItem
    
	
    # run cli gui
    $RootWindow.Run()
}