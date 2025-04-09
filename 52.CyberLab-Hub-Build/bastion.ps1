# Variables
$resourceGroupName = "bastion"
$location = "westus2"  # Change this to your preferred location
$vnetName = "bastionVnet"
$bastionHostName = "myBastionHost"
$addressSpace = "10.0.40.0/23"
$subnet1Name = "AzureBastionSubnet"
$subnet1Prefix = "10.0.40.0/24"
$subnet2Name = "subnet2"
$subnet2Prefix = "10.0.41.0/24"

# Create the resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create the virtual network
$bastionVnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix $addressSpace

# Create the subnet for the Bastion host
$subnet1 = Add-AzVirtualNetworkSubnetConfig -Name $subnet1Name -AddressPrefix $subnet1Prefix -VirtualNetwork $bastionVnet
$subnet2 = Add-AzVirtualNetworkSubnetConfig -Name $subnet2Name -AddressPrefix $subnet2Prefix -VirtualNetwork $bastionVnet

# Create the virtual network with the subnet
$bastionVnet | Set-AzVirtualNetwork

# Create the public IP address for the Bastion host
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "$bastionHostName-ip" -AllocationMethod Static -Sku Standard

# Create the Bastion host
New-AzBastion -ResourceGroupName $resourceGroupName -Name $bastionHostName -VirtualNetworkId $bastionVnet.Id -PublicIpAddressId $publicIp.Id
