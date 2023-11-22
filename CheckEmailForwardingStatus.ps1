# List of users to check
$users = @(
    # Insert users names here in the format "Jeff Jefferson",
)

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName #Your email here

# Function to check mail forwardinga
function Check-MailForwarding {
    param ($user)
    $mailbox = Get-Mailbox -Identity $user -ErrorAction SilentlyContinue
    if ($mailbox) {
        $forwardingStatus = ""
        $forwardingAddress = $mailbox.ForwardingAddress
        $forwardingSmtpAddress = $mailbox.ForwardingSmtpAddress

        if ($forwardingAddress) {
            $forwardingStatus = "Mail is being forwarded to an internal address."
        } elseif ($forwardingSmtpAddress) {
            $forwardingStatus = "Mail is being forwarded to $($forwardingSmtpAddress)."
        }

        # Check for forwarding set via inbox rules
        $inboxRules = Get-InboxRule -Mailbox $user -ErrorAction SilentlyContinue
        foreach ($rule in $inboxRules) {
            if ($rule.ForwardTo -or $rule.ForwardAsAttachmentTo) {
                $forwardingStatus += " Mail forwarding rule found: $($rule.Name)."
            }
        }

        if ($forwardingStatus -eq "") {
            "$user's mail is not being forwarded."
        } else {
            "$user - $forwardingStatus"
        }
    } else {
        "Mailbox for $user not found."
    }
}

# Check each user
foreach ($user in $users) {
    Check-MailForwarding -user $user
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false