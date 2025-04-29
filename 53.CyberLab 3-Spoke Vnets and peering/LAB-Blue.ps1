
$region = "West US 2"
$rg = "LAB-BLUE"
$vnetName = "blueVnet"
$blueSubID = Get-secret -Name "blueSub" -AsPlainText
$addressSpace = "10.0.10.0/23"
$subnet1Name = "subnet1"
$subnet1Prefix = "10.0.10.0/24"
$subnet2Name = "subnet2"
$subnet2Prefix = "10.0.11.0/24"

Set-AzContext -Subscription $blueSubID | Out-Null
New-AzResourceGroup -Name $rg -Location $region | Out-Null

############################################
# Create Virtual Network and Subnets
############################################
$vnet = New-AzVirtualNetwork -ResourceGroupName $rg `
    -Location $region -Name $vnetName `
    -AddressPrefix $addressSpace

# Create subnets
Add-AzVirtualNetworkSubnetConfig -Name $subnet1Name `
    -AddressPrefix $subnet1Prefix -VirtualNetwork $vnet

Add-AzVirtualNetworkSubnetConfig -Name $subnet2Name `
    -AddressPrefix $subnet2Prefix -VirtualNetwork $vnet

# Apply the changes to the virtual network
$vnet | Set-AzVirtualNetwork

