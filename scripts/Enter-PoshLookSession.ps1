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

	$AppInstance = [ConsoleFramework.ConsoleApplication]::Instance;
	$Window = [ConsoleFramework.Controls.Window]::new()
	$Window.Margin.Left = 2
	$Window.Margin.Right = 2
	$Window.Margin.Top = 2
	$Window.Margin.Bottom = 2
	$Window.Height = 15
	$window.Width = 20

	$FolderList = [ConsoleFramework.Controls.ListBox]::new()
	$FolderList.Name = 'Email Folders'

	$WindowHost = [ConsoleFramework.Controls.WindowsHost]::new();
	$WindowHost.MainMenu = [ConsoleFramework.Controls.Menu]::new();
	$WindowHost.MainMenu.HorizontalAlignment = 'Center';

	$MainMenu = @(
		@{
			Name = 'File'
			Title = '_File'
			Gesture = 'Alt+F'
			Items = @(
				@{
					Name = 'Open'
					Title = '_Open'
					#Click = {}
				},@{
					Name = 'Exit'
					Title = 'E_xit'
					Click = {$AppInstance.Exit()}
				}
			)

		},@{
			Name = 'Edit'
			Title = '_Edit'
			Gesture = 'Alt+E'
			#Click = {}
		},@{
			Name = 'Options'
			Title = '_Options'
			Gesture = 'Alt+O'
			#Click = {}
		}
	)

	$MainMenu | %{
		$ThisMenuItem = [ConsoleFramework.Controls.MenuItem]::new()
		$ThisMenuItem.Title = $_.Title
		$ThisMenuItem.Name = $_.Name

		if ($_.Click){
			$ThisMenuItem.Add_Click($_.Click)
		}
		if ($_.Items){
			$ThisMenuItem.Type = 'Submenu'
			$_.Items | %{
				$ThisSubmenuItem = [ConsoleFramework.Controls.MenuItem]::new()
				$ThisSubmenuItem.Title = $_.Title
				$ThisSubmenuItem.Name = $_.Name
				if ($_.Click){
					$ThisSubmenuItem.Add_Click($_.Click)
				}
				$ThisMenuItem.Items.Add($ThisSubmenuItem)
			}
		}

		$WindowHost.MainMenu.Items.Add(
			$ThisMenuItem
		)
	}


	$WindowGrid = [ConsoleFramework.Controls.Grid]::new()

	(Get-EWSFolder -Path MsgFolderRoot).FindFolders([int]::MaxValue) | ?{$_.FolderClass -eq 'IPF.Note'} | %{
		$FolderList.Items.Add($_.DisplayName)
	}

	$ThisColumn = [ConsoleFramework.Controls.ColumnDefinition]::new()
	$ThisColumn.MinWidth = 15
	$ThisColumn.MaxWidth = [int]::MaxValue

	$($ThisColumn) | %{
		$WindowGrid.ColumnDefinitions.Add($_);
	}

	$ThisRow = [ConsoleFramework.Controls.RowDefinition]::new()
	$ThisRow.MaxHeight = [int]::MaxValue
	$ThisRow.MinHeight = 20
	
	$WindowGrid.RowDefinitions.Add($ThisRow)
	$WindowGrid.Controls.Add($FolderList)

	$Window.Content = $WindowGrid;
	$WindowHost.Show($Window);


	cls;$AppInstance.Run($WindowHost);
}