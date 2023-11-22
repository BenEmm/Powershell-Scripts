# Connect to Exchange Online
# You will need to login with an account that has the necessary permissions
Connect-ExchangeOnline

# Import email addresses from a file
$emailList = Get-Content "C:\File\Path\Here\FileName.txt"

# Loop through each email address
foreach ($email in $emailList) {
    try {
        # Create the Distribution Group
        $group = New-DistributionGroup -Name $email -PrimarySmtpAddress $email -ErrorAction Stop
        Write-Host "Distribution Group created for $email"

        # Add whoever you need as a member
        # For multiple people, better to put them all in a distribution group then add that one group here
        Add-DistributionGroupMember -Identity $email -Member "Person@domain.com" -ErrorAction Stop
        Write-Host "Person@domain.com added to $email"

        # Set Delivery Management settings
        Set-DistributionGroup -Identity $email -RequireSenderAuthenticationEnabled $false
        Write-Host "Delivery management settings updated for $email"

        # Set Message Approval settings
        Set-DistributionGroup -Identity $email -ModerationEnabled $false
        Write-Host "Message approval settings updated for $email"

        # Set Membership Approval settings
        Set-DistributionGroup -Identity $email -MemberJoinRestriction Closed -MemberDepartRestriction Open
        Write-Host "Membership approvals settings updated for $email"

    } catch {
        Write-Host "Error processing ${email}: $_"
    }
}

# Disconnect from Exchange Online
# Disconnect-ExchangeOnline