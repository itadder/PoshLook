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
			Margin = @{Top=1;Bottom=1;Left=1;Right=1}
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

        $FolderConfig = @{
            Name = 'FolderContents'
            Items = {
				(Get-EWSFolder -Path "MsgFolderRoot\Inbox").FindItems([int]::MaxValue) | Select -ExpandProperty Subject
			}
        }

		$EmailConfig = @{
            Name = 'EmailContents'
            Items = $null
        }

		$Debounce = [datetime]::Now

        $WindowConfig = @{
            Title = 'Poshlook'
            Name = 'PoshlookWindow'
            #Height = '60'
            #Width = '80'
            HorizontalAlignment = 'Stretch'
            VerticalAlignment = 'Stretch'
            Margin = New-Object ConsoleFramework.Core.Thickness -Property @{
                Top = 1
                Bottom = 1
                Left = 1
                Right = 1
            }
            Content = $(
				
                $TreeConfig.Items = . $TreeConfig.Items
				$FolderConfig.Items = . $FolderConfig.Items
                #$FolderList = New-CFList @FolderConfig
				$FolderScroll = New-Object ConsoleFramework.Controls.ScrollViewer -Property @{
					MaxHeight = 25
					Width = 60
					Margin = New-Object ConsoleFramework.Core.Thickness -Property @{
						Top = 1
						Bottom = 1
						Left = 1
						Right = 1
					}
					VerticalAlignment = 'Top'
				}
				$EmailScroll = New-Object ConsoleFramework.Controls.ScrollViewer -Property @{
					MaxHeight = 25
					Width = 60
					Margin = New-Object ConsoleFramework.Core.Thickness -Property @{
						Top = 1
						Bottom = 1
						Left = 1
						Right = 1
					}
					VerticalAlignment = 'Top'
				}
                $FolderContents = New-CFList @FolderConfig
				$EmailContents = New-CFList @EmailConfig
				$TreeView = New-CFTreeView @TreeConfig
				$TreeView.Add_PropertyChanged({
					$FolderScroll.Height = $TreeView.ActualHeight
					$FolderScroll.Width = $TreeView.ActualWidth * 2.5
					$FolderScroll.Content.MinWidth = $TreeView.ActualWidth * 2.5
					$EmailScroll.Height = $TreeView.ActualHeight
					$EmailScroll.Width = $TreeView.ActualWidth * 3.5
					$EmailScroll.Content.MinWidth = $TreeView.ActualWidth * 3.5

					if (([datetime]::Now - $Debounce).TotalSeconds -ge 10) {
						try {
							Write-Verbose -Message "Changing to $($TreeView.SelectedItem.Title)" -Verbose
							$NewFolder = 
							$FolderScroll.Content.Items.Clear()
							$script:emails = (Get-EWSFolder -Path "MsgFolderRoot\$($TreeView.SelectedItem.Title)").FindItems([int]::MaxValue)
							$script:emails | Select -ExpandProperty Subject| % {
								$FolderScroll.Content.Items.Add($_)
							}
						} Catch {
							Write-Verbose -Message 'Unable to look up folder' -Verbose
						}
						$Debounce = [Datetime]::Now
					} else {
						Write-Verbose 'Debounced' -Verbose
					}
				})

				$FolderContents.Add_SelectedItemIndexChanged({
					Write-Verbose -Verbose -Message "$($EmailScroll.ActualWidth)"
					$SelectedEmail = $script:emails | Select -First 1 -Skip $FolderContents.SelectedItemIndex
					
					$SelectedEmailBody = ((( Get-EWSMessage -id ($SelectedEmail | select -ExpandProperty id) | select -ExpandProperty BodyText ) -replace '<[^>]+>','') -split "`r`n") | %{if($_){wrapText -text $_ -width ($EmailContents.ActualWidth - 5)}else{$_}}
					$EmailContents.Items.Clear()
					$SelectedEmailBody | %{
						$EmailContents.Items.Add($_)
					}

				})

                $WindowPanel = [ConsoleFramework.Controls.Panel]::new()
                $WindowPanel.Orientation = [ConsoleFramework.Controls.Orientation]::Horizontal
				
				$EmailScroll.Content = $EmailContents
				$FolderScroll.Content = $FolderContents

                [void]$WindowPanel.XChildren.Add($TreeView)
                [void]$WindowPanel.XChildren.Add($FolderScroll)
				[void]$WindowPanel.XChildren.Add($EmailScroll)
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
            Show = {
				New-CFWindow @WindowConfig
			}
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