<#
    Purpose: Get the login history for a server
#>

# Get the date one week ago

$oneWeekAgo = (Get-Date).AddDays(-7)

 

# Get the security log events for the past week

Get-WinEvent -FilterHashtable @{Logname='Security';ID=4624;StartTime=$oneWeekAgo} |

    # Select the relevant properties

    ForEach-Object {

        # Create a new object to hold the details

        $details = New-Object PSObject

 

        # Add the time the event was generated

        Add-Member -InputObject $details -MemberType NoteProperty -Name TimeGenerated -Value $_.TimeCreated

 

        # Add the username

        Add-Member -InputObject $details -MemberType NoteProperty -Name UserName -Value $_.Properties[5].Value

 

        # Output the details

        $details

    }