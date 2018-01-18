function Get-POP3Account
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$EmailAddress,
        
        [Parameter(Mandatory=$true)]
        [securestring]$password,
        
        [Parameter(Mandatory=$false)]
        [string]$port,
        
        [switch]$UseSSL
    )
    
    [Reflection.Assembly]::LoadFile("imapx.dll")
    if (Test-Path -Path "$env:USERPROFILE\Documents\poshlook\$EmailAddress.txt"){
        Get-UserChoice
    }
}