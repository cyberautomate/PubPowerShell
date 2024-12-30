<#
DESCRIPTION
Get members of all the Global, Universal or DomainLocal groups in your Active Directory
and output the data to a CSV file
PARAMETER Scope
The available scope options are Global, Universal, and DomainLocal
EXAMPLE
Get-GroupMember -Scope DomainLocal
#>

# Scope options are Universal, DomainLocal,Global
# Get-GroupMember -Scope DomainLocal

Function Get-GroupMember {
    Param(
        [parameter(Mandatory = $true)]
        [string]
        $scope
    )
    $Groups = Get-ADGroup -Filter { GroupScope -eq $scope -and Members -ne "NULL" } -Properties Name | 
    Select-Object Name, @{Name = "GroupMembers"; Expression = { (Get-ADGroupMember -Identity "$_" | 
                Select-Object -ExpandProperty SamAccountName) -join "`n" }
    }
}
$Groups | Format-Table -AutoSize -Wrap
$Groups | Out-GridView
$Groups | Export-Csv C:\scripts\groups.csv -NoTypeInformation