
[CmdletBinding()]
param (
    [Parameter()]
    [string]$ResourceGroupName = "Apps",

    [Parameter()]
    [string]$Location = "westus2",

    [Parameter()]
    [string]$VNetName = "appsvNet",

    [Parameter()]
    [string]$SubnetName = "default",

    [Parameter()]
    [string]$VMName = "testVM",

    [Parameter()]
    [string]$VMSize = "Standard_B2ms",

    [Parameter()]
    [string]$AdminUsername = "chief",

    [Parameter()]
    [string]$SshKeyPath = "~/.ssh/id_rsa.pub",

    [Parameter()]
    [int]$OsDiskSize = 128,
    
    [Parameter()]
    [string]$StorageAccountType = "StandardSSD_LRS",

    [Parameter()]
    [string]$tag = "n8n",

    [Parameter()]
    [secureString]$adminPassword = (Read-Host -AsSecureString "Enter password for $AdminUsername"),

    [Parameter()]
    [switch]$CreateResourceGroup = $false
)

# Ensure SSH key exists
if (!(Test-Path -Path $sshKeyPath)) {
    ssh-keygen -t rsa -b 2048 -f $sshKeyPath -N ""
    Write-Output "SSH key pair generated at $sshKeyPath"
}
else {
    Write-Output "SSH key pair already exists at $sshKeyPath"
}

# Read SSH public key
$sshPublicKey = Get-Content "$sshKeyPath" -Raw

# Define standard tags for all resources
$tags = @{
    "Asset"     = $tag
    "CreatedBy" = "PowerShell"
    "CreatedOn" = (Get-Date).ToString("yyyy-MM-dd")
}

# Check and create resource group if needed
if ($CreateResourceGroup) {
    Write-Host "Creating resource group $ResourceGroupName in $Location..."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $tags -Force
}
else {
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Error "Resource Group '$ResourceGroupName' not found. Use -CreateResourceGroup to create it."
        return
    }
    Write-Host "Using existing resource group $ResourceGroupName..."
}

# Check for existing VNet or create a new one
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $vnet) {
    Write-Host "Creating virtual network $VNetName with subnet $SubnetName..."
    $subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix "10.0.0.0/24"
    $vnet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName -Location $Location -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig -Tag $tags
}
else {
    Write-Host "Using existing virtual network $VNetName..."
    # Check if subnet exists
    $subnet = $vnet | Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -ErrorAction SilentlyContinue
    if (-not $subnet) {
        Write-Error "Subnet '$SubnetName' not found in virtual network '$VNetName'."
        return
    }
}

# Get subnet reference
$subnet = $vnet | Get-AzVirtualNetworkSubnetConfig -Name $SubnetName
if (-not $subnet) {
    throw "Subnet '$SubnetName' does not exist in virtual network '$VNetName'."
}

# check for NSG, create if not exists
$nsgName = "$VMName-nsg"
$nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $nsg) {
    Write-Verbose "Creating Network Security Group '$nsgName'..."
    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName `
        -Location $Location -Name $nsgName -Tag $Tags
}

# Check for NIC, create if not exists
$nicName = "$VMName-nic"
$nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $nic) {
    Write-Verbose "Creating Network Interface '$nicName'..."
    $nic = New-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Location $Location `
        -Name $nicName -SubnetId $subnet.Id -NetworkSecurityGroupId $nsg.Id -Tag $Tags
}

# Get latest Ubuntu image version
Write-Host "Finding latest Ubuntu image version..."
$publisher = "Canonical"
$offer = "Ubuntu-25_04"
$sku = "server"
$latestVersion = (Get-AzVMImage -Location $Location -PublisherName $publisher -Offer $offer -Skus $sku | Sort-Object -Property Version -Descending | Select-Object -First 1).Version

# Create VM configuration
Write-Host "Creating VM configuration..."
$vmConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize

# Configure OS settings
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $VMName -Credential (New-Object System.Management.Automation.PSCredential($AdminUsername, $adminPassword))

# Configure VM source image
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version $latestVersion

# Configure OS disk
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -DiskSizeInGB $OsDiskSize -CreateOption FromImage -StorageAccountType $StorageAccountType

# Attach network interface
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Configure SSH key
$vmConfig = Add-AzVMSshPublicKey -VM $vmConfig -KeyData $sshPublicKey -Path "/home/$AdminUsername/.ssh/authorized_keys"

# Disable boot diagnostics
$vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Disable

$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -ErrorAction SilentlyContinue
if ($vm) {
    Write-Host "VM $VMName already exists. Skipping creation."
    return
}
else {
    # Create the VM
    Write-Host "Creating Ubuntu VM $VMName... (this may take several minutes)"
    $vm = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfig -Tag $tags
}

if ($vm) {
    Write-Host "VM created successfully!"
}
