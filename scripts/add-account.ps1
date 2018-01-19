#This will be where we create new accounts
Import-Module EWS
<#
    .SYNOPSIS
        Helper Function to Add An account to a json file.
    
    .DESCRIPTION
        Helper Function to Add account to a CLIxml file or json or just passthru.
        This will add in saving a mailbox to use when connecting to poshlook
    
    .PARAMETER Mailbox
        Account or Mailbox you want to connect to Exchange in PoshLook
    
    .PARAMETER Version
        Version of Exchange Web Service.
    
    .PARAMETER ServiceUrl
        Optional URL to service (when specified, auto-discovery is not used).
    
    .PARAMETER json
        A description of the json parameter.
    
    .PARAMETER Credential
        Credentials used to authenticate to Exchange Web Service.
        Credentials used to authenticate to Exchange Web Service.
        Optional, only needed if your connecting to a differnet Mailbox
    
    .PARAMETER jsonconfig
        A description of the jsonconfig parameter.
    
    .EXAMPLE
        PS C:\> Add-Account
    
    .OUTPUTS
        string, string
    
    .NOTES
        Additional information about the function.
#>
function Add-Account {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidatePattern('\w+([-+.'''''''''''''''']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*')]
        [String]$Mailbox,
        [Parameter(Mandatory = $true,
            Position = 1)]
        #[ValidateSet('Exchange2007_SP1', 'Exchange2010', 'Exchange2010_SP1', 'Exchange2010_SP2', 'Exchange2013', 'Exchange2013_SP1', 'Exchange2016')]
        [system.string]$Version,
        [Parameter(Position = 2)]
        #[ValidatePattern('http(s)?://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?')]
        [string]$ServiceURL,
        [Parameter(Position = 3)]
        [string]$json,
        [pscredential]$Credential
    )
    
    #TODO: Connect Script
    if ($ServiceUrl -ne $null) {
$json = @"
        MailBox = $Mailbox
        Version = $Version
        ServiceURL = $ServiceURL
"@
        ConvertTo-Json -InputObject $json | Out-File "$PSScriptRoot\Config\$Mailbox.json"
    }
        
    else {
        
$json = @"
        MailBox = $Mailbox
        Version = $Version
"@

        ConvertTo-Json -InputObject $json | Out-File "$PSScriptRoot\Config\$Mailbox.json"
    }
}

