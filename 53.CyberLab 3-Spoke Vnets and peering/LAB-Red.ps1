
$region = "West US 2"
$rg = "LAB-RED"
$vnetName = "redVnet"
$redSubID = Get-secret -Name "redSub" -AsPlainText
$addressSpace = "10.0.20.0/23"
$subnet1Name = "containerSubnet"
$subnet1Prefix = "10.0.20.0/24"
$subnet2Name = "subnet2"
$subnet2Prefix = "10.0.21.0/24"

Set-AzContext -Subscription $redSubID | Out-Null
New-AzResourceGroup -Name $rg -Location $region | Out-Null

############################################
# Create Virtual Network and Subnets
############################################
$vnet = New-AzVirtualNetwork -ResourceGroupName $rg `
    -Location $region -Name $vnetName -AddressPrefix $addressSpace

# Create subnets
$delegation = New-AzDelegation -Name "containerDelegation" `
    -ServiceName "Microsoft.ContainerInstance/containerGroups"

Add-AzVirtualNetworkSubnetConfig -Name $subnet1Name `
    -AddressPrefix $subnet1Prefix -VirtualNetwork $vnet `
    -Delegation $delegation

Add-AzVirtualNetworkSubnetConfig -Name $subnet2Name `
    -AddressPrefix $subnet2Prefix -VirtualNetwork $vnet

# Apply the changes to the virtual network
$vnet | Set-AzVirtualNetwork