<# 
DESCRIPTION Uses some WMI and reading some Registry keys to get the version numbers for McAfee Security 
Center, DAT, HIP, Plash Player, Java, Adobe Acrobat, Reader and AIR. All of the results are 
put into a CSV file with the computername, IP Address, MAC Address and Serial Number 
EXAMPLE 
.\get-3rdPartySoftware.ps1 -ComputerName CL1 
.\get-3rdPartySoftware.ps1 -ComputerName CL1, CL2 
.\get-3rdPartySoftware.ps1 -ComputerName (Get-Content -Path "C:\computers.txt") 
#>

Function Get-3rdPartySoftware {
    [CmdletBinding()]
    Param([string[]]$ComputerName)

    # The results of the script are here
    $exportLocation = "C:\scripts\softwareInventory.csv"

    foreach ($Computer in $ComputerName) {
        $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer | ? { $_.IPEnabled }
        $OS = Get-WmiObject Win32_OperatingSystem -Computername $Computer
        $Hardware = Get-wmiobject Win32_computerSystem -Computername $Computer
        $username = $Hardware.Username
        $lastBoot = $OS.ConvertToDateTime($OS.LastBootUpTime)

        # Security Center Build Version
        $virusScan = Get-ItemProperty "HKLM:SOFTWARE\McAfee\MSC\AppInfo\Substitute" | Select-Object Build
            
        # DAT Version
        $Dat = Get-ItemProperty "HKLM:SOFTWARE\McAfee\AVSolution\DatReputation" | Select-Object szRepDATVer
        
        # HIP Version
        $HIPVer = Get-ItemProperty "HKLM:SOFTWARE\McAfee\HIP" | Select-Object Version
            
        # Flash Player ActiveX Version
        $FlashActiveX = Get-ItemProperty "HKLM:SOFTWARE\Macromedia\FlashPlayerActiveX" | Select-Object Version
        
        # Flash Player Plugin Version
        $FlashPlugin = Get-ItemProperty "HKLM:SOFTWARE\Macromedia\FlashPlayer" | Select-Object CurrentVersion
            
        $JavaVer = Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse |
        ForEach-Object { Get-ItemProperty $_.pspath } | Where-Object DisplayName -Like "*Java 8*" | Select-Object DisplayVersion

        # Acrobat AIR Version
        $adobeAIR = Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse |
        ForEach-Object { Get-ItemProperty $_.pspath } | Where-Object DisplayName -Like "*Adobe AIR*" | Select-Object DisplayVersion -First 1
        
        # Acrobat Reader Version
        $adobeReader = Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse |
        ForEach-Object { Get-ItemProperty $_.pspath } | Where-Object DisplayName -Like "*Adobe Acrobat Reader*" | Select-Object DisplayVersion
        
        # Acrobat Acrobat Pro Version
        $adobeAcrobat = Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse |
        ForEach-Object { Get-ItemProperty $_.pspath } | Where-Object DisplayName -Like "*Adobe Acrobat X*" | Select-Object DisplayVersion

        # Build the CSV file
        foreach ($Network in $Networks) {
            $IPAddress = $Network.IpAddress[0]
            $MACAddress = $Network.MACAddress
            $systemBios = $Bios.serialnumber
            $OutputObj = New-Object -Type PSObject
            $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
            $OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
            $OutputObj | Add-Member -MemberType NoteProperty -Name MACAddress -Value $MACAddress
            $OutputObj | Add-Member -MemberType NoteProperty -Name UserName -Value $username
            $OutputObj | Add-Member -MemberType NoteProperty -Name Last_Reboot -Value $lastboot.Date
            $OutputObj | Add-Member -MemberType NoteProperty -Name McAfee_Security_Center_Ver -Value $VirusScan.build
            $OutputObj | Add-Member -MemberType NoteProperty -Name McAfee_DatFile_Ver -Value $Dat.szRepDATVer
            $OutputObj | Add-Member -MemberType NoteProperty -Name McAfee_HIPS_Ver -Value $HIPVer.VERSION
            $OutputObj | Add-Member -MemberType NoteProperty -Name Flash_ActiveX_Ver -Value $FlashActiveX.Version
            $OutputObj | Add-Member -MemberType NoteProperty -Name Flash_Plugin_Ver -Value $FlashPlugin.CurrentVersion
            $OutputObj | Add-Member -MemberType NoteProperty -Name Acrobat_Ver -Value $adobeAcrobat.DisplayVersion
            $OutputObj | Add-Member -MemberType NoteProperty -Name AIR_Ver -Value $adobeAIR.DisplayVersion
            $OutputObj | Add-Member -MemberType NoteProperty -Name Reader_Ver -Value $adobeReader.DisplayVersion
            $OutputObj | Add-Member -MemberType NoteProperty -Name Java_Ver -Value $JavaVer.DisplayVersion
            $OutputObj | Export-Csv $exportLocation -Append
        }
    } 
}
