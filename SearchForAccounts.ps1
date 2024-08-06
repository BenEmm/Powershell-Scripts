<#

  SearchForAccounts.ps1

 

  Created by: Ben McLeod

 

  Purpose: The purpose of this script is to query large (or small) amounts of computers/servers to see if a paricular account exists on them.

           Useful for gathering info if large changes need to be made, e.g. passwords for local admin accounts or clearing up old accounts.

 

  How it works: The script takes a list of servers provided by the user, in the format of "ServerName". Put a comma between each server.

                The script then asks the user for their admin credentials at runtime to prevent plain text storage.

                The script then opens a remote session one by one for each server in the list and runs the 'net user' command.

                The script closes the connection and checks to see if the account we were searching for was in the list.

                The script then outputs a message to the screen with the outcome for each server in the list.

 

                The processing for this script is wrapped in a Try/Catch block so any errors will be handled elegantly.

#>

 

# List of servers, replace as needed:

$servers = "Example1", "Example2", "Example3"

 

# The username you're looking for

$username = "example_name" # edit this as needed

 

# Prompt for admin credentials

$adminCredential = Get-Credential -Message "Enter your admin credentials: "

 

# For each server in the list provided

foreach ($server in $servers) {

    try {

        # Open a remote session with admin credentials

        $session = New-PSSession -ComputerName $server -Credential $adminCredential -ErrorAction Stop

 

        # Run the 'net user' command so we can search local accounts

        $output = Invoke-Command -Session $session -ScriptBlock { net user }

 

        # Close the remote session

        Remove-PSSession -Session $session

 

        # Check if the username is in the output

        if ($output -match $username) {

            Write-Host "User $username exists on $server" -ForegroundColor Green

        }
        else {

            Write-Host "User $username does not exist on $server" -ForegroundColor Red

        }

    }
    catch {

        Write-Host "AN ERROR OCCURED WITH $server IT HAS BEEN SKIPPED" -ForegroundColor Yellow

    }

}