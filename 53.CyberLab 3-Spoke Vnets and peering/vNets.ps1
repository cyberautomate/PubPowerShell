##########################################
# Virtual Network Peerings
##########################################

$hubRG = "HUB"
$hubVnetName = "hubVnet"
$hubSubID = Get-Secret -Name "hubSub" -AsPlainText
$redRG = "LAB-RED"
$redVnetName = "redVnet"
$redSubID = Get-Secret -Name "redSub" -AsPlainText
$blueRG = "LAB-BLUE"
$blueVnetName = "blueVnet"
$blueSubID = Get-Secret -Name "blueSub" -AsPlainText

##########################################
# Peering between hubVnet and redVnet
##########################################
$context = Set-AzContext -Subscription $hubSubID
$hubVnet = Get-AzVirtualNetwork -Name $hubVnetName -ResourceGroupName $hubRG
$hubVnet | Add-AzVirtualNetworkPeering -Name $redRG -RemoteVirtualNetworkId "/subscriptions/$redSubID/resourceGroups/$redRG/providers/Microsoft.Network/virtualNetworks/$redVnetName" -AllowForwardedTraffic -AllowGatewayTransit

$context = Set-AzContext -Subscription $redSubID
$redVnet = Get-AzVirtualNetwork -Name $redVnetName -ResourceGroupName $redRG
$redVnet | Add-AzVirtualNetworkPeering -Name $hubRG -RemoteVirtualNetworkId "/subscriptions/$hubSubID/resourceGroups/$hubRG/providers/Microsoft.Network/virtualNetworks/$hubVnetName" -AllowForwardedTraffic -AllowGatewayTransit -UseRemoteGateways

##########################################
# Peering between hubVnet and blueVnet
##########################################
$context = Set-AzContext -Subscription $hubSubID
$hubVnet = Get-AzVirtualNetwork -Name $hubVnetName -ResourceGroupName $hubRG
$hubVnet | Add-AzVirtualNetworkPeering -Name $blueRG -RemoteVirtualNetworkId "/subscriptions/$blueSubID/resourceGroups/$blueRG/providers/Microsoft.Network/virtualNetworks/$blueVnetName" -AllowForwardedTraffic -AllowGatewayTransit

$context = Set-AzContext -Subscription $blueSubID
$blueVnet = Get-AzVirtualNetwork -Name $blueVnetName -ResourceGroupName $blueRG
$blueVnet | Add-AzVirtualNetworkPeering -Name $hubRG -RemoteVirtualNetworkId "/subscriptions/$hubSubID/resourceGroups/$hubRG/providers/Microsoft.Network/virtualNetworks/$hubVnetName" -AllowForwardedTraffic -AllowGatewayTransit -UseRemoteGateways
