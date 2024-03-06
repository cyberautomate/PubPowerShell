@description('Whether or not to deploy a VPN Gateway in the Hub')
@allowed([
  'Yes'
  'No'
])
param deployVpnGateway string = 'Yes'

@description('The SKU of the Gateway, if deployed')
@allowed([
  'Basic'
  'VpnGw1'
  'VpnGw2'
  'VpnGw3'
])
param gatewaySku string = 'VpnGw1'

@description('Location for all resources.')
param location string = resourceGroup().location

// Hub
var hubVnetName = 'hubVnet'
var hubVnetPrefix = '10.20.0.0/16'
var sharedSubnetName = 'SharedSubnet'
var sharedSubnetPrefix = '10.20.1.0/24'
var gatewaySubnetName = 'GatewaySubnet'
var gatewaySubnetPrefix = '10.20.2.0/24'
var gatewayName = 'hubVpnGateway'
var gatewayPIPName = 'hubVpnGatewayPublicIp'
var subnetGatewayId = hubVnetName_gatewaySubnet.id

// OnPrem network vars
var onPremSpokeVnetName = 'spokeonPremVnet'
var onPremSpokeVnetPrefix = '10.30.0.0/23'
var onPremSpokeWorkloadSubnetPrefix = '10.30.1.0/24'

// Ghosts network vars
var ghostsSpokeVnetName = 'spokeghostsVnet'
var ghostsSpokeVnetPrefix = '10.40.0.0/23'
var ghostsSpokeWorkloadSubnetPrefix = '10.40.1.0/24'

// HoneyPot network vars
var honeyPotSpokeVnetName = 'spokepotsVnet'
var honeyPotSpokeVnetPrefix = '10.50.0.0/23'
var honeyPotSpokeWorkloadSubnetPrefix = '10.50.1.0/24'

var spokeWorkloadSubnetName = 'WorkloadSubnet'
var hubID = hubVnet.id
var onPremSpokeID = onPremSpokeVnet.id
var ghostsSpokeID = ghostsSpokeVnet.id

resource hubVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource hubVnetName_sharedSubnet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' = {
  parent: hubVnet
  name: sharedSubnetName
  properties: {
    addressPrefix: sharedSubnetPrefix
  }
}

resource hubVnetName_gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' = if (deployVpnGateway == 'Yes') {
  parent: hubVnet
  name: gatewaySubnetName
  properties: {
    addressPrefix: gatewaySubnetPrefix
  }
  dependsOn: [
    hubVnetName_sharedSubnet
  ]
}

resource onPremSpokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: onPremSpokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        onPremSpokeVnetPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource onPremSpokeVnetName_spokeWorkloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' = {
  parent: onPremSpokeVnet
  name: spokeWorkloadSubnetName
  properties: {
    addressPrefix: onPremSpokeWorkloadSubnetPrefix
  }
}

resource ghostsSpokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: ghostsSpokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        ghostsSpokeVnetPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource ghostsSpokeVnetName_spokeWorkloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' = {
  parent: ghostsSpokeVnet
  name: spokeWorkloadSubnetName
  properties: {
    addressPrefix: ghostsSpokeWorkloadSubnetPrefix
  }
}

resource honeyPotSpokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: honeyPotSpokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        honeyPotSpokeVnetPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource honeyPotSpokeVnetName_spokeWorkloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2019-11-01' = {
  parent: honeyPotSpokeVnet
  name: spokeWorkloadSubnetName
  properties: {
    addressPrefix: honeyPotSpokeWorkloadSubnetPrefix
  }
}

// Peerings
resource hubVnetName_gwPeering_hubVnetName_onPremSpokeVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'Yes') {
  parent: hubVnet
  name: 'gwPeering_${hubVnetName}_${onPremSpokeVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: onPremSpokeID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet
    hubVnetName_gatewaySubnet

    onPremSpokeVnetName_spokeWorkloadSubnet
  ]
}

resource hubVnetName_peering_hubVnetName_onPremSpokeVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'No') {
  parent: hubVnet
  name: 'peering_${hubVnetName}_${onPremSpokeVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: onPremSpokeID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet

    onPremSpokeVnetName_spokeWorkloadSubnet
  ]
}

resource hubVnetName_gwPeering_hubVnetName_ghostsSpokeVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'Yes') {
  parent: hubVnet
  name: 'gwPeering_${hubVnetName}_${ghostsSpokeVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: ghostsSpokeID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet
    hubVnetName_gatewaySubnet

    ghostsSpokeVnetName_spokeWorkloadSubnet
  ]
}

resource hubVnetName_peering_hubVnetName_ghostsSpokeVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'No') {
  parent: hubVnet
  name: 'peering_${hubVnetName}_${ghostsSpokeVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: ghostsSpokeID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet

    ghostsSpokeVnetName_spokeWorkloadSubnet
  ]
}

resource onPremSpokeVnetName_gwPeering_onPremSpokeVnetName_hubVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'Yes') {
  parent: onPremSpokeVnet
  name: 'gwPeering_${onPremSpokeVnetName}_${hubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet
    hubVnetName_gatewaySubnet

    onPremSpokeVnetName_spokeWorkloadSubnet
    gateway
  ]
}

resource onPremSpokeVnetName_peering_onPremSpokeVnetName_hubVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'No') {
  parent: onPremSpokeVnet
  name: 'peering_${onPremSpokeVnetName}_${hubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet

    onPremSpokeVnetName_spokeWorkloadSubnet
  ]
}

resource ghostsSpokeVnetName_gwPeering_ghostsSpokeVnetName_hubVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'Yes') {
  parent: ghostsSpokeVnet
  name: 'gwPeering_${ghostsSpokeVnetName}_${hubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet
    hubVnetName_gatewaySubnet

    ghostsSpokeVnetName_spokeWorkloadSubnet
    gateway
  ]
}

resource ghostsSpokeVnetName_peering_ghostsSpokeVnetName_hubVnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = if (deployVpnGateway == 'No') {
  parent: ghostsSpokeVnet
  name: 'peering_${ghostsSpokeVnetName}_${hubVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubID
    }
  }
  dependsOn: [
    hubVnetName_sharedSubnet

    ghostsSpokeVnetName_spokeWorkloadSubnet
  ]
}

resource gatewayPIP 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: gatewayPIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource gateway 'Microsoft.Network/virtualNetworkGateways@2019-11-01' = if (deployVpnGateway == 'Yes') {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetGatewayId
          }
          publicIPAddress: {
            id: gatewayPIP.id
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
  }
}
