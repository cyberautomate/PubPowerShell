break
# VARs
$location = 'eastus'
$rgName = 'secureLab-RG'
$keyVaultName = 'kv-SecureLab'
$UPN = 'dahall@chiefslab.com'
$secretvalue = Read-Host -AsSecureString
$secretName = 'vmPassword'


# Login to whatever cloud you want to deploy to.
Connect-AzAccount

# If you have more than one subscription make sure you deploy to the correct one
Get-AzSubscription

# Name                                  Id                                   TenantId                             State
# ----                                  --                                   --------                             -----
# Visual Studio Enterprise Subscription 1079ebde-cb3d-4b2b-96fe-76b1a64b825d 239d7e53-e932-4035-9ed5-be52373ea790 Enabled
# Chiefslab-T3                          53fd7700-54e4-4664-a720-f7bc631909c2
# ChiefsLab-Ops                         986c78a5-0e1b-4d04-8fe5-884f03e86c17
# Chiefslab-T0                          47f19c77-2a69-4737-80f3-c8b32330d1ce

Set-AzContext -Subscription '986c78a5-0e1b-4d04-8fe5-884f03e86c17'

# Create a RG for the Lab Resources
New-AzResourceGroup -Name $rgName -Location $location

###########################
# KeyVault Deployment
###########################
# Deploy the Keyvault
New-AzKeyVault -Name $keyVaultName -ResourceGroupName $rgName -Location $location
# Set permissions on KeyVault
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -UserPrincipalName $UPN -PermissionsToSecrets get,set,delete
# Create a secret in the KeyVault
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $secretvalue
# Get the secret for use in creating a VM
$secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -AsPlainText

###########################
# vNet Deployment
###########################
#TODO - Move all the variables up to the top of the script block to all paramerterization
# Create the Hub vNet
$HubVNetName = "HUB-vNet"
$HubVNetAddressSpace = "10.0.0.0/24"
$HubSubnetName = "HubSubnet"
$HubSubnetAddressPrefix = "10.0.0.0/25"
$HubVNet = New-AzVirtualNetwork -Name $HubVNetName -ResourceGroupName $rgName -Location $Location -AddressPrefix $HubVNetAddressSpace
$HubSubnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $HubSubnetName -VirtualNetwork $HubVNet -AddressPrefix $HubSubnetAddressPrefix
$HubVNet = Set-AzVirtualNetwork -VirtualNetwork $HubVNet

# Create the onPrem vNet
$onPremVNetName = "onPrem-vNet"
$onPremVNetAddressSpace = "10.0.1.0/24"
$onPremSubnetName = "onPremSubnet"
$onPremSubnetAddressPrefix = "10.0.1.0/24"
$onPremVNet = New-AzVirtualNetwork -Name $onPremVNetName -ResourceGroupName $rgName -Location $Location -AddressPrefix $onPremVNetAddressSpace
$onPremSubnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $onPremSubnetName -VirtualNetwork $onPremVNet -AddressPrefix $onPremSubnetAddressPrefix
$onPremVNet = Set-AzVirtualNetwork -VirtualNetwork $onPremVNet

# Create the ghosts vNet
$ghostsVNetName = "ghosts-vNet"
$ghostsVNetAddressSpace = "10.0.2.0/24"
$ghostsSubnetName = "ghostsSubnet"
$ghostsSubnetAddressPrefix = "10.0.2.0/24"
$ghostsVNet = New-AzVirtualNetwork -Name $ghostsVNetName -ResourceGroupName $rgName -Location $Location -AddressPrefix $ghostsVNetAddressSpace
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

###########################
# VPN Gateway Deployment
###########################

# VPN Gateway Variables
$GatewaySubnetAddressPrefix = "10.0.0.128/25" # Adjust the address space according to your VNet configuration
$VirtualNetworkName = $HubVNetName
$PublicIPName = "SecureLabVPNPiP"
$GatewayIPConfigName = "SecureLabVPNPiPConfig"
$GatewayName = "VPN-Gateway"
$GatewaySku = "VpnGw1" # Choose an appropriate SKU (Basic, VpnGw1, VpnGw2, VpnGw3, etc.)
$GatewayType = "Vpn" # or "ExpressRoute"
$VpnType = "RouteBased" # or "PolicyBased" - PolicyBased is for Basic SKU only

# Retrieve the virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $rgName

# Create the gateway subnet if it doesn't exist
$GatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $VirtualNetwork
if (-Not $GatewaySubnet) {
    Add-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $VirtualNetwork -AddressPrefix $GatewaySubnetAddressPrefix | Set-AzVirtualNetwork
}
$gatewaySubnet = (Get-azvirtualNetwork -Name HUB-vNet).subnets[1].Ids

# Create a new public IP address that will be used by the VPN gateway
$PublicIP = New-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $rgName -Location $Location -AllocationMethod Static

# Create the configuration for the VPN gateway
$GatewayIPConfig = New-AzVirtualNetworkGatewayIpConfig -Name $GatewayIPConfigName -SubnetId $GatewaySubnet -PublicIpAddressId $PublicIP.Id

# Create the VPN gateway
New-AzVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $rgName -Location $Location -IpConfigurations $GatewayIPConfig -GatewayType $GatewayType -VpnType $VpnType -GatewaySku $GatewaySku -Verbose


###########################
# VM Deployment
###########################

# Define the VM configuration
$resourceGroupName = 'secureLab-RG'
$location = 'your-location' # replace with your Azure location, e.g., 'eastus'
$vmName = 'DC'
$vmSize = 'Standard_B2ms'
$adminUsername = 'chief'
$adminPassword = ConvertTo-SecureString 'YourSecurePassword' -AsPlainText -Force # replace with your password
$windowsImage = Get-AzVMImage -Location $location -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2022-Datacenter-smalldisk' | Sort-Object -Property PublishedDate -Descending | Select-Object -First 1

# Create the VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)) -ProvisionVMAgent -EnableAutoUpdate |
    Set-AzVMSourceImage -PublisherName $windowsImage.PublisherName -Offer $windowsImage.Offer -Skus $windowsImage.Skus -Version $windowsImage.Version |
    Add-AzVMNetworkInterface -Id (New-AzNetworkInterface -Name "$vmName-nic" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $yourSubnetId -ErrorAction Stop).Id # replace $yourSubnetId with your subnet ID

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig




















# Deploy above with Defedner and Sentinel 
# - Azure Firewall standard SKU
# - Sentinel deployed to the Log Analytics Workspace
# - Defender for Cloud Enabled

$name = "Sentinel-MLZ"
$location = 'eastus'
$templateFile = 'mlz.bicep'
$resourcePrefix = "MyMLZ"
$deployDefender = $true
$deploySentinel = $true
$deployRemoteAccess = $true

New-AzSubscriptionDeployment -Name $name `
-Location $location `
-TemplateFile $templateFile `
-resourcePrefix $resourcePrefix `
-deployDefender $deployDefender `
-deploySentinel $deploySentinel `
-deployRemoteAccess $deployRemoteAccess `
-Verbose

# Get all Resource Groups after MLZ deployment
Get-AzResourceGroup | Select-Object -Property ResourceGroupName

# Deploy VM to MLZ
$vmTemplateFile = 'main.bicep'
$adDeploymentName = 'Deploy-T3-Client'
$resourceGroupName = 'mymlz-rg-tier3-mlz'

New-AzResourceGroupDeployment -TemplateFile $vmTemplateFile -Name $adDeploymentName -ResourceGroupName $resourceGroupName -Verbose








# Cleanup after deployment
$filter = 'mymlz-rg'

Get-AzResourceGroup | Where-Object ResourceGroupName -match $filter | Remove-AzResourceGroup -Force -verbose