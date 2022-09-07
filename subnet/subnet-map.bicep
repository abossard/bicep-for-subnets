//
// This module's purpose is to map the subnet item of the JSON into an ARM Subnet Properties
// so check out what kind of properties are already supported and expand and change if required
//
param name string
param subnet object
param nsgId string
param vnetName string
param deploySubnet bool = false

var subnetData = {
  name: name
  properties: {
    addressPrefix: subnet.addressPrefix
    delegations: contains(subnet, 'delegation') ? [
      {
        name: '${name}-delegation'
        properties: {
          serviceName: subnet.delegation
        }
      }
    ] : []
    natGateway: contains(subnet, 'natGatewayId') ? {
      id: subnet.natGatewayId
    } : null
    networkSecurityGroup: !empty(nsgId) ? {
      id: nsgId
    } : null
    routeTable: contains(subnet, 'udrId') ? {
      id: subnet.udrId
    } : null
    privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
    privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
    serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : null
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource subnetResource 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = if (deploySubnet) {
  name: subnetData.name
  parent: vnet
  properties: subnetData.properties
}

output subnet object = subnetData
