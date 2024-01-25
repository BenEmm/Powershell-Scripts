# Install the module only if it's not already installed
Install-Module -Name ExchangeOnlineManagement

# Import the Exchange Online Management module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName ### "Insert Admin Email Here" ###

# Ask for the user's email address
$userEmail = Read-Host -Prompt "Enter the email address of the user to enable AutoExpandingArchive for: "

# Enable the auto-expanding archive for the specified mailbox
Enable-Mailbox $userEmail -AutoExpandingArchive

# Retrieve and display mailbox information
Get-Mailbox $userEmail | FL AutoExpandingArchiveEnabled