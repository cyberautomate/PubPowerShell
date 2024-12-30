$labName = 'TestLab'
$domain = 'test.lab'
$adminAcct = 'Administrator'
$adminPass = 'YourPasswordHere'
$labsources = "D:\LabSources"

#Create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

#Network definition
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace 10.1.1.0/24

#Domain definition with the domain admin account
Add-LabDomainDefinition -Name $domain -AdminUser $adminAcct -AdminPassword $adminPass
Set-LabInstallationCredential -Username $adminAcct -Password $adminPass

#Default parameter values for all the machines
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'               = $labName
    'Add-LabMachineDefinition:ToolsPath'             = "$labSources\Tools"
    'Add-LabMachineDefinition:IsDomainJoined'        = $true
    'Add-LabMachineDefinition:DnsServer1'            = '10.1.1.1'
    'Add-LabMachineDefinition:OperatingSystem'       = 'Windows Server 2016 Datacenter (Desktop Experience)'
    'Add-LabMachineDefinition:DomainName'            = $domain
    'Add-LabMachineDefinition:Memory'                = 4GB
    'Add-LabMachineDefinition:Processors'            = 1
    'Add-LabMachineDefinition:MinMemory'             = 1GB
    'Add-LabMachineDefinition:MaxMemory'             = 4GB
    'Add-LabMachineDefinition:EnableWindowsFirewall' = $false
}

# Root Domain Controller
Add-LabMachineDefinition -Name TestDC -IpAddress 10.1.1.1 -Roles RootDC

# Test SVR 1
Add-LabMachineDefinition -Name TestSVR1 -IpAddress 10.1.1.2

# Test SVR 2
Add-LabMachineDefinition -Name TestSVR2 -IpAddress 10.1.1.3

Install-Lab

Show-LabDeploymentSummary -Detailed