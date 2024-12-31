<#
DESCRIPTION
Reads a txt file containing computer names and attempts to ping each machine. If the ping is successful, 
Copy the contents of c:\Install from the source computer to c:\install on the target machine. 
Once the copy is complete test that the install package is present (in my case the Adobe Reader DC offline installer) 
and then launch the installation silently with no reboot or user interaction required.
This example uses the Adobe Reader install package but it can easily be modified to install other software packages.
REQUIREMENTS
1. The appropriate rights to ping and copy on the remote machine.
2. A computers.txt file with a list of computer names
3. PowerShell remoting enabled if the target is a client OS
4. Appropriate permissions on the target machine to install software
NOTES
Tested with Windows 10 source and Windows Server 2K12 R2 target
Adobe reader DC download: http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501020060/AcroRdrDC1501020060_en_US.exe
#>

# This is the file that contains the list of computers you want 
# to copy the folder and files to. Change this path IAW your folder structure.
$computers = Get-Content "C:\scripts\computers.txt"

# This is the directory you want to copy to the computer (IE. c:\folder_to_be_copied)
$source = "c:\install"

# On the destination computer, where do you want the folder to be copied?
$dest = "c$"

$testPath = "c:\install\AcroRdrDC1501020060_en_US.exe"

foreach ($computer in $computers) {
    if (test-Connection -Cn $computer -quiet) {
        Copy-Item $source -Destination \\$computer\$dest -Recurse -Force

        if (Test-Path -Path $testPath) {
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe c:\Install\AcroRdrDC1501020060_en_US.exe /sAll /msi /norestart ALLUSERS=1 EULA_ACCEPT=YES }
            Write-Host -ForegroundColor Green "Installation successful on $computer"
        }
    }
    else {
        Write-Host -ForegroundColor Red "$computer is not online, Install failed"
    }
}