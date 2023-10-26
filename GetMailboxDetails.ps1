Install-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName @championsukplc.com

<#
    This script checks a given users mailbox for their:
    - Current inbox usage and their inboxes maximum size
    - Current archive usage and their Archive's maximum storage.
#>

# Edit this line to change the user we search for:
$UserToCheck = "@championsukplc.com"

# Variables
$Mailbox = Get-Mailbox -Identity $UserToCheck
$MailboxStatistics = Get-MailboxStatistics -Identity $UserToCheck
$ArchiveStatus = $mailbox.ArchiveStatus
$TotalMailboxSize = $MailboxStatistics.DatabaseProhibitSendQuota

# Print results
Write-Host ("User: " + $UserToCheck)
Write-Host ("`nMailbox Size: " + $MailboxStatistics.TotalItemSize + " out of " + $Mailbox.ProhibitSendReceiveQuota)
Write-Host ("Archive Space Used: " + $ArchiveStatus)

# If Archive is active, print info about it, else report inactive
if ($ArchiveStatus -eq "Active") {
    $ArchiveStatistics = Get-MailboxStatistics -Identity $UserToCheck -Archive | Select TotalItemSize
    Write-Host ("Archive Size: " + $ArchiveStatistics.TotalItemSize + " out of " + $Mailbox.ArchiveQuota)
} else {
    Write-Host ("Archive Status: Inactive")
}