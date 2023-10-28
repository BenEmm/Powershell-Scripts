Install-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName bmcleod@championsukplc.com

# Initialize an empty array to store the gathered information
$Result=@()

# Fetch all user mailboxes without any size constraints
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
$totalmbx = $mailboxes.Count
$i = 0

# Iterate through each mailbox to collect archive-related details
$mailboxes | ForEach-Object {
    $i++
    $mbx = $_
    $size = $null

    # Show a progress indicator for the ongoing operation
    Write-Progress -activity "Processing $mbx" -status "$i out of $totalmbx completed"

    # Check if the Archive feature is activated for the mailbox
    if ($mbx.ArchiveStatus -eq "Active"){
        # Fetch statistics for the active archive of the mailbox
        $mbs = Get-MailboxStatistics $mbx.UserPrincipalName -Archive

        # Calculate the archive size in MB and GB
        # (Assumes the TotalItemSize string format is like '1234 bytes (12.34 KB)')
        if ($mbs.TotalItemSize -ne $null){
            $sizeString = $mbs.TotalItemSize.ToString().Split('(')[1].Split(' ')[0].Replace(',', '')
            $sizeMB = [math]::Round(($sizeString / 1MB), 2)
            $sizeGB = "{0:N4}" -f ($sizeMB / 1000)  # IEC standard: 1 GB = 1000 MB, formatted to 4 decimal places
            $size = "$sizeMB ($sizeGB GB)"
        } else {
            $size = "0 (0.0000 GB)"
        }
    }

    # Create a new PSObject to store the mailbox and archive details
    # Properties like ArchiveWarningQuota and ArchiveQuota are conditionally added based on ArchiveStatus
    $Result += New-Object -TypeName PSObject -Property $([ordered]@{
        UserName = $mbx.DisplayName
        UserPrincipalName = $mbx.UserPrincipalName
        ArchiveStatus = $mbx.ArchiveStatus
        ArchiveName = $mbx.ArchiveName
        ArchiveState = $mbx.ArchiveState
        ArchiveMailboxSize = $size  # This now contains both MB and GB
        ArchiveWarningQuota = if ($mbx.ArchiveStatus -eq "Active") {$mbx.ArchiveWarningQuota} Else { $null}
        ArchiveQuota = if ($mbx.ArchiveStatus -eq "Active") {$mbx.ArchiveQuota} Else { $null}
        AutoExpandingArchiveEnabled = $mbx.AutoExpandingArchiveEnabled
    })
}

# Initialize filename and counter
$filename = "C:\Archive-Mailbox-Report.csv"
$counter = 1

# Check if the file already exists, and increment the filename if it does
while (Test-Path $filename) {
    $filename = "C:\Archive-Mailbox-Report($counter).csv"
    $counter++
}

# Export the assembled information to a new or incremented CSV file
$Result | Export-CSV $filename -NoTypeInformation -Encoding UTF8

# Display the file location and name when complete
Write-Host "Data exported to $filename"