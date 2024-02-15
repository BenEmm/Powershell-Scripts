# This script takes a list of users and writes the results to a file in the root of the C: drive.

# Connect to Azure AD
Connect-AzureAD

# List of user names
$userNames = @(
    # "Jeff Jefferson", "Bill Billson", "Emma Emmerson","Will Willson" #... add all other names here
)

# Path for the output file
$outputFilePath = "C:\licensed_status.txt"

# Total number of users
$totalUsers = $userNames.Count
$currentCount = 0

# Check each user's license status and write to file
foreach ($userName in $userNames) {
    # Update the progress bar
    $currentCount++
    $progress = ($currentCount / $totalUsers) * 100
    Write-Progress -Activity "Checking User Licenses" -Status "$currentCount of $totalUsers processed" -PercentComplete $progress

    # Get the user's Azure AD object
    $user = Get-AzureADUser -Filter "displayName eq '$userName'"

    if ($user) {
        # Check if the user has licenses assigned
        $licenses = $user.AssignedLicenses

        if ($licenses.Count -gt 0) {
            "$userName is licensed." | Out-File -FilePath $outputFilePath -Append
        }
        else {
            "$userName is unlicensed." | Out-File -FilePath $outputFilePath -Append
        }
    }
    else {
        "User $userName not found in Azure AD." | Out-File -FilePath $outputFilePath -Append
    }
}

# Completion message
Write-Host "License check complete. Results saved to $outputFilePath"