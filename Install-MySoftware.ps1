# You must have Chocolately installed first

# Usage example
# Install-MySoftware -Computers dc1,dc2,svr12,svr16 -Packages 'powershell.portable','microsoft-edge','microsoft-windows-terminal'
Function Install-MySoftware {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [string[]]$Computers,

        [Parameter()]
        [string[]]$Packages
    )

    $liveComputers = [Collections.ArrayList]@()

    foreach ($computer in $computers) {
        if (Test-Connection -ComputerName $computer -Quiet -count 1) {
            $null = $liveComputers.Add($computer)
        }
        else {
            Write-Verbose -Message ('{0} is unreachable' -f $computer) -Verbose
        }
    }

    $liveComputers | ForEach-Object {
        Invoke-Command -ComputerName $_ -ScriptBlock {
            $Result = [Collections.ArrayList]@()

            $testchoco = Test-Path 'C:\ProgramData\chocolatey'
            if ($testchoco -eq $false) {
                Write-Verbose -Message "Chocolately is not installed on $($Env:COMPUTERNAME). Please install and try again." -Verbose
            } 
            # TLS 1.2 is required for Chocolatey to install
            # https://chocolatey.org/blog/remove-support-for-old-tls-versions
            # Check if using TLS 1.2
            $tls = [System.Net.ServicePointManager]::SecurityProtocol.HasFlag([Net.SecurityProtocolType]::Tls12)

            if ($tls -eq $false) {
                [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            }

            foreach ($Package in $using:Packages) {
                choco Install $Package -y | Out-File -FilePath "c:\Windows\Temp\choco-$Package.txt"
                if ($LASTEXITCODE -eq '1641' -or '3010') {
                    # Reference: https://chocolatey.org/docs/commandsinstall#exit-codes
                    # create new custom object to keep adding information to it
                    $Result += New-Object -TypeName PSCustomObject -Property @{
                        ComputerName     = $Env:COMPUTERNAME
                        InstalledPackage = $Package
                    }
                }
                else {
                    Write-Verbose -Message "Packages failed on $($Env:COMPUTERNAME), see logs in c:\windows\temp" -Verbose
                }
            } $Result 
        }     
    
    } | Select-Object ComputerName, InstalledPackage | Sort-Object -Property ComputerName
}
