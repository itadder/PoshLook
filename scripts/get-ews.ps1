# Written by Ben Penney https://sysadminben.wordpress.com
#Modifed By Justino Garcia

# Set the credential prompt to show up in the console.
 
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name ConsolePrompting -Value $true
clear
$creds =  Get-Credential 
$mail = $creds.GetNetworkCredential().username
$password = $creds.GetNetworkCredential().password

#This would of been great idea, but it not secure.
#$mail= read-host "Please enter your O365 Email:"

#$password = Read-host "Enter your Password:"- 
 

# Set the path to your copy of EWS Managed API 
$dllpath = "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll" 
# Load the Assemply 
[void][Reflection.Assembly]::LoadFile($dllpath) 

# Create a new Exchange service object 
$service = new-object Microsoft.Exchange.WebServices.Data.ExchangeService 

#These are your O365 credentials
$Service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials($mail,$password)

# this TestUrlCallback is purely a security check
$TestUrlCallback = {
    param ([string] $url)
    if ($url -eq "https://autodiscover-s.outlook.com/autodiscover/autodiscover.xml") {$true} else {$false}
}
# Autodiscover using the mail address set above
$service.AutodiscoverUrl($mail,$TestUrlCallback)

# create Property Set to include body and header of email
$PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)

# set email body to text
$PropertySet.RequestedBodyType = [Microsoft.Exchange.WebServices.Data.BodyType]::Text;

# Set how many emails we want to read at a time
$numOfEmailsToRead = 10
# Index to keep track of where we are up to. Set to 0 initially. 
$index = 0 

# Do/while loop for paging through the folder 
do 
{ 
    # Set what we want to retrieve from the folder. This will grab the first $pagesize emails
    $view = New-Object Microsoft.Exchange.WebServices.Data.ItemView($numOfEmailsToRead,$index) 
    # Retrieve the data from the folder 
    $findResults = $service.FindItems([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox,$view) 
    foreach ($item in $findResults.Items)
    {
        # load the additional properties for the item
        $item.Load($propertySet)

        # Output the result
        write-output "##################"
        clear
        "From: $($item.From.Name)"
        "------------------------"
        "To:   $($item.ToRecipients)"
        "------------------------"
        "Subject: $($item.Subject)" | Format-Table -AutoSize
        "------------------------"
        "Body: $($Item.Body.Text)"
        
        "" 
    } 
    # Increment $index to next block of emails
    $index += $numOfEmailsToRead
} while ($findResults.MoreAvailable) # Do/While there are more emails to retrieve

