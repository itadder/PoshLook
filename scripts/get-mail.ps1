<#                                                                                                              
.Synopsis                                                                                                       
.DESCRIPTION                                                                                                    
.EXAMPLE                                                                                                        
   Get-Mail -provider "imap.google.com"                                                  
.LINK                                                                                                           
   Github project: https://github.com/poshlook/PoshLook                                                         
#>
   
function Get-Mail(
[Parameter]
#mail provider to connect to
[string]$provider
[string]$auth
)
{
Add-Type -Path "$psScriptRoot\dlls\ImapX.dll"

$client = New-Object Imapx.ImapClient("$provider", 993,$true)
$credentials = New-Object ImapX.Authentication.PlainCredentials("","")

$client.connect()
$client.login($credentials)
$client.folders.$location.search(criteria)
$client.disconnect()
Remove-Variable -Name client
}


