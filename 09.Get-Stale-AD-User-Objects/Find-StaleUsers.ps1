<#
DESCRIPTION
1. Search an OU for user accounts that have not authenticated in x number of days ($days)
2. Disable those accounts
3. Move those disabled user accounts to another OU ($disabledOU)
4. Also creates a logfile of all the users that were disabled ($logpath)
EXAMPLE
.\Get-StaleUsers.ps1
#>

# Gets todays Date
$date = Get-Date

# Number of days it's been since the computer authenticated to the domain
# In my case 1 day
$hours = "-1"

# Sets a description on that object so other admins know why the object was disabled
$description = "Disabled by SignalWarrant on $date due to inactivity for 1 days."

# This is the OU you are searching for Stale Computer accounts
$ou = "OU=_Test_Users,DC=signalwarrant,DC=local"

# This is where the disabled accounts get moved to.
$disabledOU = "OU=_Disabled_Users,DC=signalwarrant,DC=local"

# path to the log file
$logpath = "c:\scripts\disabled_users.csv"

$finduser = Get-Aduser –filter * -SearchBase $ou -properties cn, lastlogondate | 
Where-Object { $_.LastLogonDate –le [DateTime]::Today.AddHours($hours) -and ($_.lastlogondate -ne $null) }

$finduser | export-csv $logpath
$finduser | Set-Aduser -Description $description –passthru | Disable-ADAccount

write-host -foregroundcolor Green "Searching OU for disabled User Accounts"
[System.Threading.Thread]::Sleep(500)

$disabledAccounts = Search-ADAccount -AccountDisabled -UsersOnly -SearchBase $ou

write-host -foregroundcolor Green "Moving disabled Users to the Disabled_Users OU"
[System.Threading.Thread]::Sleep(500)

$disabledAccounts | Move-ADObject -TargetPath $disabledOU

write-host -foregroundcolor Green "Script Complete"