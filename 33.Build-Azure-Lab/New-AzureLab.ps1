Function New-AzureLab {
    <#
    SYNOPSIS
    New-AzureLab will create 1 or multiple VMs in Azure based on input parameters from a CSV
    DESCRIPTION
    Create a CSV file like below:
    VMName,Location,InterfaceName,ResourceGroupName,VMSize,ComputerName
    SP,EastUS,SP_Int,SignalWarrant_RG,Basic_A2,SP
    The function will read the input from the CSV file and create VMs in an Azure Resource Group
    PARAMETER csvpath
    The full path to your CSV file (eg c:\scripts\VMs.csv)
    EXAMPLE
    New-AzureLab -csvpath c:\scripts\VMs.csv
    Imports the applicable values from the CSV file
    NOTES
    1. I already had a Resource Group in Azure therefore I put all the VMs in the same group.
    2. I already had a VM network created, all my VMs are in the same network.
    LINK
    URLs to related sites
    A good writeup on the process - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-powershell
    Azure VM size values - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
    Azure VM Publisher, Offer, SKUs, Version info for various VM types - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage
    INPUTS
    CSV file path
    #>
    
    Param (
        [Parameter(Mandatory = $True, HelpMessage = 'Enter the Path to your CSV')]
        [string]$csvpath
    )
    # Lets make sure the CSV file is actually there
    $testpath = Test-Path -Path $csvpath
    If (!$testpath) {
        clear-host
        write-host -ForegroundColor Red '***** Invalid CSV Path *****' -ErrorAction Stop
    }
    else {
        # This will the be local username and password for each VM
        $Credential = Get-Credential
        # Import the information from my CSV
        Import-Csv -Path "$csvPath" | ForEach-Object {
            # Get the Storage Account Informaiton
            $StorageAccount = Get-AzureRmStorageAccount
            # This is the naming convention for the OS Disk
            $OSDiskName = $_.'VMName' + '_OSDisk'
            # Network Information
            $PublicIP = New-AzureRmPublicIpAddress -Name $_.'InterfaceName' -ResourceGroupName $_.'ResourceGroupName' -Location $_.'Location' -AllocationMethod Dynamic
            $VMNetwork = Get-AzureRmVirtualNetwork
            $Interface = New-AzureRmNetworkInterface -Name $_.'InterfaceName' -ResourceGroupName $_.'ResourceGroupName' -Location $_.'Location' -SubnetId $VMNetwork.Subnets[0].Id -PublicIpAddressId $PublicIP.Id
            ## Setup local VM object
            $VirtualMachine = New-AzureRmVMConfig -VMName $_.'VMName' -VMSize $_.'VMSize'
            $VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $_.'ComputerName' -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
            $VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version 'latest'
            $VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
            $OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + 'vhds/' + $OSDiskName + '.vhd'
            $VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage
            ## Create the VM in Azure
            New-AzureRmVM -ResourceGroupName $_.'ResourceGroupName' -Location $_.'Location' -VM $VirtualMachine -Verbose
        }
    }
}