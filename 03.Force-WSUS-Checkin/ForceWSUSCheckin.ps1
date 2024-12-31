<#
PARAMETER ComputerName
See the examples below, the computername can be one or 
many computer names
EXAMPLE
.\force-WSUScheckin.ps1 -ComputerName CL1
.\force-WSUScheckin.ps1 -ComputerName CL1 -verbose
.\force-WSUScheckin.ps1 -ComputerName CL1, CL2 -verbose
.\force-WSUScheckin.ps1 -ComputerName (Get-Content -Path "C:\computers.txt") -verbose
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string[]]$ComputerName

)
$service = Get-Service -Name wuauserv

# Check to see if the wuauserv service is stopped
if ($service.Status -eq "Stopped") {
    # If the service is stopped we're going to start it and force WSUS checkin
    # then Exit
    Write-verbose "1. WUAUSERV is stopped... starting"
    Invoke-Command -ComputerName $ComputerName -scriptblock { Start-Service wuauserv }
    [System.Threading.Thread]::Sleep(3000)

    Write-verbose "2. Forcing WSUS Checkin"
    Invoke-Command -ComputerName $ComputerName -scriptblock { wuauclt.exe /detectnow }
    [System.Threading.Thread]::Sleep(1500)

    Write-verbose "3. Checkin Complete"
    Exit
}
else {
    # If the service is started we'll just force the WSUS checkin and Exit
    Write-verbose "1. Forcing WSUS Checkin"
    Invoke-Command -ComputerName $ComputerName -scriptblock { wuauclt.exe /detectnow }
    [System.Threading.Thread]::Sleep(1500)

    Write-Verbose "2. Checkin Complete"
    Exit
}