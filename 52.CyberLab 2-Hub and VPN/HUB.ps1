

$region = "West US 2"
$rg = "HUB"
$vnetName = "hubVnet"
$hubSubID = Get-Secret -Name "hubSub" -AsPlainText
$addressSpace = "10.0.0.0/22"
$gatewaySubnetName = "GatewaySubnet"
$gatewaySubnetPrefix = "10.0.0.0/24"
$defaultSubnetName = "appSubnet"
$defaultSubnetPrefix = "10.0.1.0/24"
$containersSubnetName = "ContainerSubnet"
$containersSubnetPrefix = "10.0.2.0/24"
$bastionSubnetName = "AzureBastionSubnet"
$bastionSubnetPrefix = "10.0.3.0/24"

Set-AzContext -Subscription $hubSubID | Out-Null
New-AzResourceGroup -Name $rg -Location $region | Out-Null

############################################
# Create Virtual Network and Subnets
############################################
$vnet = New-AzVirtualNetwork -ResourceGroupName $rg -Location $region -Name $vnetName -AddressPrefix $addressSpace

# Create subnets
$delegation = New-AzDelegation -Name "containerDelegation" -ServiceName "Microsoft.ContainerInstance/containerGroups"

Add-AzVirtualNetworkSubnetConfig -Name $gatewaySubnetName -AddressPrefix $gatewaySubnetPrefix -VirtualNetwork $vnet
Add-AzVirtualNetworkSubnetConfig -Name $defaultSubnetName -AddressPrefix $defaultSubnetPrefix -VirtualNetwork $vnet
Add-AzVirtualNetworkSubnetConfig -Name $containersSubnetName -AddressPrefix $containersSubnetPrefix -VirtualNetwork $vnet -Delegation $delegation -ServiceEndpoint "Microsoft.Storage"
Add-AzVirtualNetworkSubnetConfig -Name $bastionSubnetName -AddressPrefix $bastionSubnetPrefix -VirtualNetwork $vnet

# Apply the changes to the virtual network
$vnet | Set-AzVirtualNetwork

############################################
# Create Log Analytics Workspace and Sentinel
############################################
$workspaceName = "labLAW"

# Create the Log Analytics Workspace
$workspace = New-AzOperationalInsightsWorkspace -ResourceGroupName $rg `
    -Name $workspaceName `
    -Location $region `
    -Sku "PerGB2018"

# Enable Sentinel Option 1
New-AzSentinelOnboardingState -ResourceGroupName $rg `
    -WorkspaceName $WorkspaceName `
    -Name "default"
# Enable Sentinel Option 2
New-AzResourceGroupDeployment -ResourceGroupName $rg `
    -TemplateUri "https://raw.githubusercontent.com/Azure/Azure-Sentinel/refs/heads/master/Tools/ARM-Templates/Onboarding/OnboardSentinel.json" `
    -workspaceName $workspaceName `
    -workspaceLocation $region

############################################
# Create VPN gateway
############################################
$gatewayName = "hubVpnGateway"
$sku = "VpnGw2AZ"
$gatewayType = "Vpn"
$vpnType = "RouteBased"
$p2sAddressPool = "172.16.0.0/24"
$tunnelType = "OpenVPN"
$aadTenant = Get-secret -Name "aadTenant" -AsPlainText
$audience = Get-secret -Name "aadAudience" -AsPlainText
$issuer = Get-secret -Name "aadIssuer" -AsPlainText
$publicIPName1 = "PublicIP1"

$ngwpip = New-AzPublicIpAddress -Name $publicIPName1 -ResourceGroupName $rg -Location $region -AllocationMethod Static -Zone "1"
$vnet = Get-AzVirtualNetwork -Name $vnetName
$subnet = $vnet | Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet"
$ngwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name ngwipconfig -SubnetId $subnet.Id -PublicIpAddressId $ngwpip.Id

New-AzVirtualNetworkGateway -Name $gatewayName -ResourceGroupName `
    $rg -Location $region -IpConfigurations $ngwIpConfig `
    -GatewayType $gatewayType -VpnType $vpnType `
    -GatewaySku $sku -VpnClientProtocol $tunnelType `
    -VpnClientAddressPool $p2sAddressPool -AadTenantUri $aadTenant `
    -AadIssuerUri $issuer -AadAudienceId $audience