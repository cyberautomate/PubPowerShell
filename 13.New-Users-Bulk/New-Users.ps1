# DO NOT EVER WRITE CODE WITH PASSWORDS IN CLEAR TEXT
$ou = "OU=_Test_Users,DC=signalwarrant,DC=local"
$file = 'c:\scripts\users.csv'
$password = "P@ssword123456"

Import-CSV $file | ForEach-Object {
    $user = New-ADUser `
        -Name ($_.Name) `
        -SamAccountName ($_.samAccountName) `
        -Path $ou `
        -AccountPassword (ConvertTo-SecureString -AsPlainText $password -force )`
        -Enabled $true `
        -ChangePasswordAtLogon $true
}