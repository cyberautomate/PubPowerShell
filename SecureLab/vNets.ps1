# Login to Azure if not already logged in
# Connect-AzAccount

# Set your subscription - replace 'YourSubscriptionName' with your actual subscription name
# $subscriptionName = "YourSubscriptionName"
# Select-AzSubscription -SubscriptionName $subscriptionName

# Define the Resource Group
$ResourceGroupName = "HubSpokeNetworkRG"
$Location = "EastUS" # Change this to your desired Azure region

# Create the Resource Group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Create the Hub vNet
$HubVNetName = "HUB-vNet"
$HubVNetAddressSpace = "10.0.0.0/16"
$HubSubnetName = "HubSubnet"
$HubSubnetAddressPrefix = "10.0.0.0/24"
$HubVNet = New-AzVirtualNetwork -Name $HubVNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $HubVNetAddressSpace
$HubSubnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $HubSubnetName -VirtualNetwork $HubVNet -AddressPrefix $HubSubnetAddressPrefix
$HubVNet = Set-AzVirtualNetwork -VirtualNetwork $HubVNet

# Create the onPrem vNet
$onPremVNetName = "onPrem-vNet"
$onPremVNetAddressSpace = "10.0.1.0/24"
$onPremSubnetName = "onPremSubnet"
$onPremSubnetAddressPrefix = "10.0.1.0/24"
$onPremVNet = New-AzVirtualNetwork -Name $onPremVNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $onPremVNetAddressSpace
$onPremSubnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $onPremSubnetName -VirtualNetwork $onPremVNet -AddressPrefix $onPremSubnetAddressPrefix
$onPremVNet = Set-AzVirtualNetwork -VirtualNetwork $onPremVNet

# Create the ghosts vNet
$ghostsVNetName = "ghosts-vNet"
$ghostsVNetAddressSpace = "10.0.2.0/24"
$ghostsSubnetName = "ghostsSubnet"
$ghostsSubnetAddressPrefix = "10.0.2.0/24"
$ghostsVNet = New-AzVirtualNetwork -Name $ghostsVNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $ghostsVNetAddressSpace
$ghostsSubnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $ghostsSubnetName -VirtualNetwork $ghostsVNet -AddressPrefix $ghostsSubnetAddressPrefix
$ghostsVNet = Set-AzVirtualNetwork -VirtualNetwork $ghostsVNet

# Peer onPrem vNet with HUB vNet
$onPremToHubPeeringName = "onPremToHubPeering"
Add-AzVirtualNetworkPeering -Name $onPremToHubPeeringName -VirtualNetwork $onPremVNet -RemoteVirtualNetworkId $HubVNet.Id

# Peer HUB vNet with onPrem vNet
$HubToOnPremPeeringName = "HubToOnPremPeering"
Add-AzVirtualNetworkPeering -Name $HubToOnPremPeeringName -VirtualNetwork $HubVNet -RemoteVirtualNetworkId $onPremVNet.Id

# Peer ghosts vNet with HUB vNet
$ghostsToHubPeeringName = "ghostsToHubPeering"
Add-AzVirtualNetworkPeering -Name $ghostsToHubPeeringName -VirtualNetwork $ghostsVNet -RemoteVirtualNetworkId $HubVNet.Id

# Peer HUB vNet with ghosts vNet
$HubToGhostsPeeringName = "HubToGhostsPeering"
Add-AzVirtualNetworkPeering -Name $HubToGhostsPeeringName -VirtualNetwork $HubVNet -RemoteVirtualNetworkId $ghostsVNet.Id
