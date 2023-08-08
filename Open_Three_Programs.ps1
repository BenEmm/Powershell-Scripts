# Open 3 applications script.

# Path to the first application - Discord
$appPath1 = "YOUR PATH HERE\Discord.exe"

# Path to the second application - Brave Browser
$appPath2 = "YOUR PATH HERE\brave.exe"

# Path to the third application - Steam
$appPath3 = "YOUR PATH HERE\steam.exe"

# Add more applications as needed...

# Function to launch an application
function Launch-App ($appPath) {
    if (Test-Path -Path $appPath) {
        # Launch the application
        Start-Process $appPath
        Write-Host "Application at $appPath started successfully."
    } else {
        Write-Host "Application at $appPath not found."
    }
}

# Launch the applications
Launch-App $appPath1
Launch-App $appPath2
Launch-App $appPath3
