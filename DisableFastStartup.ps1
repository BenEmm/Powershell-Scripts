# This script disables fast start up on Windows so that clicking "Shutdown" actually turns the computer off.

# Define the registry path for the Power settings
$Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"

# Define the name of the registry entry to modify (HiberbootEnabled for Fast Startup)
$Name = "HiberbootEnabled"

# Check if the registry path exists
if (-not $(Test-Path $Path)) {
    # If the path does not exist, create it
    New-Item -Path $Path -Force | Out-Null

    # Create the registry entry for disabling Fast Startup and set its value to 0
    New-ItemProperty -Path $Path -Name $Name -Value 0 -PropertyType DWord -Force | Out-Null
} else {
    # If the path already exists, just create or update the registry entry
    New-ItemProperty -Path $Path -Name $Name -Value 0 -PropertyType DWord -Force | Out-Null
}
