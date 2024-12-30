<#
DESCRIPTION
Creates Active Directory Users in Bulk using a CSV file. Requires a typed password
and a confirmation that matches to execute.
#>

###############################################################
#
# Confirm-Password function
#
###############################################################
Function confirm-Password {
    $match = $false
    while ($match -eq $false) {
        $PWD1 = Read-Host "ENTER PASSWORD"
        $PWD2 = Read-Host "CONFIRM PASSWORD"

        if ($PWD1 -ne $PWD2) {
            Write-Warning "Passwords Do Not Match - Please Try Again ..."
            break
        } 
        if ($PWD1 -eq "" -or $PWD2 -eq "") {
            Write-Warning "Password Cannot be BLANK - Please Try Again ..."
            break
        } 
        return $PWD1
    }
}

###############################################################
#
# End Confirm-Password function
#
###############################################################
$import = 'c:\scripts\users.csv'
$password = confirm-password

if ($password -ne "") {
    Import-CSV $import | ForEach-Object {
        $user = New-ADUser `
            -SamAccountName ($_.FName + "." + $_.Lname) `
            -Name ($_.FName + " " + $_.LName) `
            -Displayname ($_.FName + " " + $_.LName) `
            -UserPrincipalName ($_.UserPrincipalName) `
            -Surname ($_.LName) `
            -GivenName ($_.Fname)  `
            -Path ($_.ou) `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $password -force )`
            -Enabled $true `
            -PasswordNeverExpires $false `
            -ChangePasswordAtLogon $true `
            -PassThru
    }
}