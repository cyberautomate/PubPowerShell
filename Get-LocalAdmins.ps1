Function Get-LocalAdmins {
<#
.SYNOPSIS
Gets the members of the local administrators of the computer 
and outputs the result to a CSV file.

.PARAMETER Computers
Specifies the Computer names of devices to query

.INPUTS
System.String. Get-LocalAdmins can accept a string value to
determine the Computers parameter.

.EXAMPLE
Get-LocalAdmins -Computers CL1,CL2

.EXAMPLE
Get-LocalAdmins -Computers (Get-Content -Path "$env:HOMEPATH\Desktop\computers.txt")

.EXAMPLE
Get-LocalAdmins -Computers DC,SVR8 | Format-Table -AutoSize -Wrap

.EXAMPLE
Get-LocalAdmins -Computers DC,SVR8 | Export-Csv -Path "$env:HOMEPATH\Desktop\LocalAdmin.csv" -NoTypeInformation

.LINK
Source script: https://gallery.technet.microsoft.com/223cd1cd-2804-408b-9677-5d62c2964883
#>

    Param(
        [Parameter(Mandatory)]
        [string[]]$Computers
        )
    # testing the connection to each computer via ping before
    # executing the script
    foreach ($computer in $Computers) {
        if (Test-Connection -ComputerName $computer -Quiet -count 1) {
            $livePCs += $computer
        } else {
            Write-Verbose -Message ('{0} is unreachable' -f $computer) -Verbose
        }
    }

    $list = new-object -TypeName System.Collections.ArrayList
    foreach ($computer in $livePCs) {
        $admins = Get-WmiObject -Class win32_groupuser -ComputerName $computer | 
            Where-Object {$_.groupcomponent -like '*"Administrators"'} 
        $obj = New-Object -TypeName PSObject -Property @{
            ComputerName = $computer
            LocalAdmins = $null
        }
        foreach ($admin in $admins) {
            $null = $admin.partcomponent -match '.+Domain\=(.+)\,Name\=(.+)$' 
            $null = $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
            $obj.Localadmins += $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
        }
        $null = $list.add($obj)
    }
    $list
}
