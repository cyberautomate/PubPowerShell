<#
DESCRIPTION
1. Search an OU for computer accounts that have not authenticated in x number of days ($days)
2. Disable those accounts
3. Move those disabled computer accounts to another OU ($disabledOU)
4. Also creates a logfile of all the computers that were disabled ($logpath)
#>

####### Edit these Variables
# Gets todays Date
$date = Get-Date

# Number of days it's been since the computer authenticated to the domain
# In my case 1 day
$days = "-1"

# Sets a description on that object so other admins know why the object was disabled
$description = "Disabled by SignalWarrant on $date due to inactivity for 1 days."

# This is the OU you are searching for Stale Computer accounts
$ou = "CN=Computers,DC=signalwarrant,DC=local"

# This is where the disabled accounts get moved to.
$disabledOU = "OU=Disabled_Computers,DC=signalwarrant,DC=local"

# path to the log file
$logpath = "c:\scripts\stale_computers.csv"
####### Edit these Variables

# Finding Stale Computers
$findcomputers = Get-adcomputer –filter * -SearchBase $ou -properties cn, LastLogonDate | 
Where-object { $_.LastLogonDate –le [DateTime]::Today.AddDays($days) -and ($_.LastLogonDate -ne $null) }

# Create a CSV containing all the Stale Computer Information
$findcomputers | export-csv $logpath

# Disable the Stale Computer Accounts
$findcomputers | set-adcomputer -Description $description –passthru | Disable-ADAccount

# Find all the Stale Computer Accounts we just disabled
$disabledAccounts = Search-ADAccount -AccountDisabled -ComputersOnly -SearchBase $ou

# Move the Disabled accounts to $disabledOU
$disabledAccounts | Move-ADObject -TargetPath $disabledOU