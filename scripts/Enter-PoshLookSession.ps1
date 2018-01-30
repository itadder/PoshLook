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
    Begin{
        if (-not (Get-EWSService -InformationAction Stop)) {
            $SelectedParams = $PSBoundParameters
            Write-Verbose -Message 'Connecting to EWS Service'
            Connect-EWSService @SelectedParams
        }

        $TreeConfig = @{
            Name = 'Email Folders'
			Margin = @{Top=2;Bottom=2;Left=2;Right=2}
			HorizontalAlignment = 'Stretch' 
			VerticalAlignment = 'Top'
            Items = {
				$SortFolders = @{
					Inbox = [int]::MaxValue
					Archive = [int]::MaxValue - 1
					Scheduled = [int]::MaxValue - 2
				}

				[string[]]((Get-EWSFolder -Path MsgFolderRoot).FindFolders([int]::MaxValue) | ?{$_.FolderClass -eq 'IPF.Note'} | Select DisplayName,@{N='Sort';E={$SortFolders[$_.DisplayName]}} | sort Sort -Descending | Select -ExpandProperty DisplayName)
			}
        }

        $FolderContents = @{
            Name = 'FolderContents'
            Items = {
				(Get-EWSFolder -Path "MsgFolderRoot\Inbox").FindItems([int]::MaxValue) | Select -ExpandProperty Subject -First 10
				@('asdfasdf','asdfasdfasfdasf','q5r42353454')
			}
        }

        $WindowConfig = @{
            Title = 'Poshlook'
            Name = 'PoshlookWindow'
            #Height = '60'
            #Width = '80'
            HorizontalAlignment = 'Stretch'
            VerticalAlignment = 'Stretch'
            Margin = New-Object ConsoleFramework.Core.Thickness -Property @{
                Top = 2
                Bottom = 2
                Left = 2
                Right = 2
            }
            Content = $(
				
                $TreeConfig.Items = . $TreeConfig.Items
				$FolderContents.Items = . $FolderContents.Items
                #$FolderList = New-CFList @FolderConfig
                $FolderContents = New-CFList @FolderContents
				$TreeView = New-CFTreeView @TreeConfig
				$TreeView.Add_PropertyChanged({
					$FolderContents.Items.Clear()
					(Get-EWSFolder -Path "MsgFolderRoot\$($TreeView.SelectedItem.Title)").FindItems([int]::MaxValue) | Select -ExpandProperty Subject -First 10 | % {
						$FolderContents.Items.Add($_)
					}
				})
                $WindowPanel = [ConsoleFramework.Controls.Panel]::new()
                $WindowPanel.Orientation = [ConsoleFramework.Controls.Orientation]::Horizontal

                [void]$WindowPanel.XChildren.Add($TreeView)
                [void]$WindowPanel.XChildren.Add($FolderContents)
                $WindowPanel
            )
        }

        [hashtable[]]$MenuItems = @(
		    @{
			    Name = 'File'
			    Title = '_File'
			    Gesture = 'Alt+F'
			    Items = [hashtable[]]@(
				    @{
					    Name = 'Open'
					    Title = '_Open'
					    #Click = {}
				    },
                    @{
					    Name = 'Exit'
					    Title = 'E_xit'
					    Click = {$AppInstance.Exit()}
				    }
			    )

		    },
            @{
			    Name = 'Edit'
			    Title = '_Edit'
			    Gesture = 'Alt+E'
			    #Click = {}
		    },
            @{
			    Name = 'Options'
			    Title = '_Options'
			    Gesture = 'Alt+O'
			    #Click = {}
		    }
	    )
        $WindowHostConfig = @{
            MainMenu = {New-CFMenu -Items $MenuItems -HorizontalAlignment 'Center'}
            Show = {New-CFWindow @WindowConfig}
        }
    }
    Process{}
    End{
        
        $AppInstance = New-CFInstance

        [string[]]($WindowHostConfig.Keys) | %{
            $WindowHostConfig[$_] = . $WindowHostConfig[$_]
        }
        $WindowHost = New-CFWindowHost @WindowHostConfig

	    cls;$AppInstance.Run($WindowHost);
    }
}