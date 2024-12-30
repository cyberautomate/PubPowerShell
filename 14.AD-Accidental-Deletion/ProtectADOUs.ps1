<#
DESCRIPTION
Searches all OUs in Active Directory, or a subset of OUs and looks for the 
ProtectedFromAccidentalDeletion property is set to $false.
The code at the bottom of the script will find the OUs and set them to
Protectedfromaccidental $true
#>

# OPTION 1
# Find all OUs that are not protected from accidental deletion
Get-ADObject -Filter * -Properties CanonicalName, ProtectedFromAccidentalDeletion |
Where-Object { $_.ProtectedFromAccidentalDeletion -eq $false -and $_.ObjectClass -eq "organizationalUnit" } | 
Select-Object CanonicalName, ProtectedFromAccidentalDeletion |
Out-GridView


# OPTION 2
# Find a smaller subset of OUs that are not protected from accidental deletion
Get-ADObject -Filter * -Properties CanonicalName, ProtectedFromAccidentalDeletion -SearchBase "OU=_Groups,DC=signalwarrant,DC=local" |
Where-Object { $_.ProtectedFromAccidentalDeletion -eq $false -and $_.ObjectClass -eq "organizationalUnit" } |
Set-ADObject -ProtectedFromAccidentalDeletion $True