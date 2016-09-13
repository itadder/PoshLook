function Get-UserChoice
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$text
    )
    
    Add-Menu -filepath "Menu\choice.json"
}