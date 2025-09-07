# ================================================
#       BEN'S HOMELAB SCRIPTS - Banner
# ================================================
Write-Host "
 ____             _       _   _                      _          _     
| __ )  ___ _ __ ( )___  | | | | ___  _ __ ___   ___| |    __ _| |__  
|  _ \ / _ \ '_ \|// __| | |_| |/ _ \| '_ ` _ \ / _ \ |   / _` | '_ \ 
| |_) |  __/ | | | \__ \ |  _  | (_) | | | | | |  __/ |__| (_| | |_) |
|____/ \___|_| |_| |___/ |_| |_|\___/|_| |_| |_|\___|_____\__,_|_.__/ 
/ ___|  ___ _ __(_)_ __ | |_ ___                                      
\___ \ / __| '__| | '_ \| __/ __|                                     
 ___) | (__| |  | | |_) | |_\__ \                                     
|____/ \___|_|  |_| .__/ \__|___/                                     
                  |_|                                                  
" -ForegroundColor Cyan

# ================================================
#       Active Directory Management Script
# ================================================

# Function to add a new user
function Add-NewUser {
    try {
        Write-Host "`n--- Add a New User ---`n" -ForegroundColor Cyan
        $FirstName = Read-Host "Enter First Name"
        $LastName  = Read-Host "Enter Last Name"
        $Sam       = Read-Host "Enter sAMAccountName (logon name)"
        $UPN       = "$Sam@ben.local"
        $Password  = Read-Host "Enter Password" -AsSecureString
        $DisplayName = "$FirstName $LastName"
        $OUPath = "OU=LabUsers,DC=ben,DC=local"

        $existingUser = Get-ADUser -Filter {SamAccountName -eq $Sam} -ErrorAction SilentlyContinue

        if ($existingUser) {
            Write-Host "Error: User '$Sam' already exists." -ForegroundColor Red
            return
        }

        New-ADUser `
            -Name $DisplayName `
            -GivenName $FirstName `
            -Surname $LastName `
            -SamAccountName $Sam `
            -UserPrincipalName $UPN `
            -Path $OUPath `
            -AccountPassword $Password `
            -Enabled $true `
            -ErrorAction Stop

        for ($i = 0; $i -le 100; $i += 20) {
            Write-Progress -Activity "Creating user $DisplayName" -Status "Processing..." -PercentComplete $i
            Start-Sleep -Milliseconds 300
        }

        $verifyUser = Get-ADUser -Filter {SamAccountName -eq $Sam} -ErrorAction SilentlyContinue

        if ($verifyUser) {
            Write-Host "Success: User '$DisplayName' created!" -ForegroundColor Green

            $addToGroups = Read-Host "Do you want to add $DisplayName to groups? (Y/N)"
            if ($addToGroups -match '^[Yy]$') {
                Write-Host "`nSelect groups to add $DisplayName to:" -ForegroundColor Cyan
                Write-Host "  1. Users"
                Write-Host "  2. Domain Admins"
                Write-Host "  3. Remote Desktop Users"
                $selection = Read-Host "Enter your choice(s), e.g. 1,3"
                $choices = $selection -split ',' | ForEach-Object { $_.Trim() }

                $total = $choices.Count
                $count = 0

                foreach ($choice in $choices) {
                    $count++
                    $percent = ($count / $total) * 100
                    Write-Progress -Activity "Adding $DisplayName to groups" -Status "Processing group $choice..." -PercentComplete $percent

                    switch ($choice) {
                        1 { Add-ADGroupMember -Identity "Users" -Members $Sam -ErrorAction SilentlyContinue; Write-Host "Added to Users" -ForegroundColor Green }
                        2 { Add-ADGroupMember -Identity "Domain Admins" -Members $Sam -ErrorAction SilentlyContinue; Write-Host "Added to Domain Admins" -ForegroundColor Green }
                        3 { Add-ADGroupMember -Identity "Remote Desktop Users" -Members $Sam -ErrorAction SilentlyContinue; Write-Host "Added to Remote Desktop Users" -ForegroundColor Green }
                        Default { Write-Host "Unknown option: $choice" -ForegroundColor Yellow }
                    }
                }
                Write-Progress -Activity "Adding $DisplayName to groups" -Completed
            }
        } else {
            Write-Host "Verification failed. Check AD manually." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to delete a user
function Remove-User {
    try {
        Write-Host "`n--- Delete a User ---`n" -ForegroundColor Cyan
        $Sam = Read-Host "Enter sAMAccountName of the user to delete"
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $Sam} -ErrorAction SilentlyContinue

        if ($existingUser) {
            $confirm = Read-Host "Are you sure you want to delete '$($existingUser.Name)'? (Y/N)"
            if ($confirm -match '^[Yy]$') {
                for ($i = 0; $i -le 100; $i += 25) {
                    Write-Progress -Activity "Deleting user $($existingUser.Name)" -Status "Processing..." -PercentComplete $i
                    Start-Sleep -Milliseconds 300
                }

                Remove-ADUser -Identity $Sam -Confirm:$false
                Write-Progress -Activity "Deleting user $($existingUser.Name)" -Completed
                Write-Host "User '$($existingUser.Name)' deleted." -ForegroundColor Green
            } else { Write-Host "Deletion cancelled." -ForegroundColor Yellow }
        } else { Write-Host "No user found with sAMAccountName '$Sam'." -ForegroundColor Yellow }
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to disable a user
function Disable-User {
    try {
        Write-Host "`n--- Disable a User Account ---`n" -ForegroundColor Cyan
        $Sam = Read-Host "Enter sAMAccountName of the user to disable"
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $Sam} -ErrorAction SilentlyContinue

        if ($existingUser) {
            $confirm = Read-Host "Are you sure you want to disable '$($existingUser.Name)'? (Y/N)"
            if ($confirm -match '^[Yy]$') {
                for ($i = 0; $i -le 100; $i += 25) {
                    Write-Progress -Activity "Disabling user $($existingUser.Name)" -Status "Processing..." -PercentComplete $i
                    Start-Sleep -Milliseconds 300
                }

                Disable-ADAccount -Identity $Sam
                Write-Progress -Activity "Disabling user $($existingUser.Name)" -Completed
                Write-Host "User '$($existingUser.Name)' has been disabled." -ForegroundColor Green
            } else { Write-Host "Disable action cancelled." -ForegroundColor Yellow }
        } else { Write-Host "No user found with sAMAccountName '$Sam'." -ForegroundColor Yellow }
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to enable a user
function Enable-User {
    try {
        Write-Host "`n--- Enable a User Account ---`n" -ForegroundColor Cyan
        $Sam = Read-Host "Enter sAMAccountName of the user to enable"
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $Sam} -ErrorAction SilentlyContinue

        if ($existingUser) {
            $confirm = Read-Host "Are you sure you want to enable '$($existingUser.Name)'? (Y/N)"
            if ($confirm -match '^[Yy]$') {
                for ($i = 0; $i -le 100; $i += 25) {
                    Write-Progress -Activity "Enabling user $($existingUser.Name)" -Status "Processing..." -PercentComplete $i
                    Start-Sleep -Milliseconds 300
                }

                Enable-ADAccount -Identity $Sam
                Write-Progress -Activity "Enabling user $($existingUser.Name)" -Completed
                Write-Host "User '$($existingUser.Name)' has been enabled." -ForegroundColor Green
            } else { Write-Host "Enable action cancelled." -ForegroundColor Yellow }
        } else { Write-Host "No user found with sAMAccountName '$Sam'." -ForegroundColor Yellow }
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to reset a user password
function Reset-Password {
    try {
        Write-Host "`n--- Reset User Password ---`n" -ForegroundColor Cyan
        $Sam = Read-Host "Enter sAMAccountName of the user"
        $existingUser = Get-ADUser -Filter {SamAccountName -eq $Sam} -ErrorAction SilentlyContinue

        if ($existingUser) {
            $NewPassword = Read-Host "Enter the new password" -AsSecureString
            $confirm = Read-Host "Are you sure you want to reset the password for '$($existingUser.Name)'? (Y/N)"

            if ($confirm -match '^[Yy]$') {
                for ($i = 0; $i -le 100; $i += 25) {
                    Write-Progress -Activity "Resetting password for $($existingUser.Name)" -Status "Processing..." -PercentComplete $i
                    Start-Sleep -Milliseconds 300
                }

                Set-ADAccountPassword -Identity $Sam -NewPassword $NewPassword -Reset
                Set-ADUser -Identity $Sam -ChangePasswordAtLogon $true
                Write-Progress -Activity "Resetting password" -Completed
                Write-Host "Password for '$($existingUser.Name)' has been reset." -ForegroundColor Green
            } else {
                Write-Host "Password reset cancelled." -ForegroundColor Yellow
            }
        } else {
            Write-Host "No user found with sAMAccountName '$Sam'." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ================================================
# Main Menu
# ================================================
# Array of goodbye messages
$goodbyeMessages = @(
    "Exiting... Goodbye!",
    "Exiting... Goodbye!",
    "Exiting... Goodbye!",
    "Exiting... Goodbye!",
    "Exiting... Goodbye!",
    "Exiting... Goodbye!",
    "Exiting... May the force be with you",
    "Exiting... Live long and prosper.",
    "Exiting... May your uptime be long and your errors be few.",
    "Exiting... Hasta la vista, baby!",
    "Exiting... Keep calm and script on.",
    "Exiting... Catch you on the flip side!"
)

# ================================================
# Main Menu
# ================================================
do {
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "          Active Directory Manager" -ForegroundColor White
    Write-Host "============================================`n" -ForegroundColor Cyan
    Write-Host "1. Add a new user"
    Write-Host "2. Delete an existing user"
    Write-Host "3. Disable a user account"
    Write-Host "4. Enable a user account"
    Write-Host "5. Reset a user password"
    Write-Host "6. Exit`n"

    $choice = Read-Host "Enter your choice (1-6)"

    switch ($choice) {
        1 { Add-NewUser }
        2 { Remove-User }
        3 { Disable-User }
        4 { Enable-User }
        5 { Reset-Password }
        6 { 
            # Pick a random message
            $randomMessage = Get-Random -InputObject $goodbyeMessages
            Write-Host "`n$randomMessage" -ForegroundColor Cyan 
        }
        Default { Write-Host "Invalid choice, please try again." -ForegroundColor Yellow }
    }

} while ($choice -ne '6')

