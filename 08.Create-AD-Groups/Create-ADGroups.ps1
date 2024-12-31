<#
DESCRIPTION
Read Active Directory group info from groups.csv and create the groups.    
Example CSV File:
GroupName	 GroupCategory 	 GroupScope	   OU
Finance	     Security	     Global	       OU=_Groups,DC=signalwarrant,DC=local
R&D	         Security	     Global	       OU=_Groups,DC=signalwarrant,DC=local
IT	         Security	     Global	       OU=_Groups,DC=signalwarrant,DC=local
HR	         Security	     Global	       OU=_Groups,DC=signalwarrant,DC=local
Executive	 Security	     Global	       OU=_Groups,DC=signalwarrant,DC=local
EXAMPLE
.\create-groups.ps1
#>

$csv = Import-Csv -Path "c:\scripts\groups.csv"

ForEach ($item In $csv) { 
    $create_group = New-ADGroup -Name $item.GroupName -GroupCategory $item.GroupCategory -groupScope $item.GroupScope -Path $item.OU 
    Write-Host -ForegroundColor Green "Group $($item.GroupName) created!" 
}