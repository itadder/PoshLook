$Public = @( Get-ChildItem -Path $PSScriptRoot\scripts\*.ps1 -ErrorAction silentlyContinue)
$Private = @( Get-ChildItem -Path $PSScriptRoot\scripts\helpers\*.ps1 -ErrorAction SilentlyContinue )


#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Export Public functions

Export-ModuleMember -Function $Public.Basename
