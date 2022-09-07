@description('Array containing subnets to create within the Virtual Network. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?tabs=bicep#subnetpropertiesformat')
param subnets object =  {
    subnet1:  {
      addressPrefix: '10.0.1.0/24'
      privateEndpointNetworkPolicies: 'disabled'
      privateLinkServiceNetworkPolicies: 'disabled'
    }
}
param location string = resourceGroup().location

var egressBlockRules = loadJsonContent('../nsg-egress-block-rules.json')
module nsgMap 'nsg-map.bicep' = [for (subnet, index) in items(subnets): {
  name: '${subnet.key}-nsg-map'
  params: {
    additionalRules: [for (targetSubnetName, innerIndex) in subnet.value.restrictEgressTo: {
      name: '${targetSubnetName}-allow'
      properties: {
        access: 'Allow'
        description: 'Allow ${subnet.key} subnet to access ${targetSubnetName} subnet'
        destinationAddressPrefix: subnets[targetSubnetName].addressPrefix
        destinationPortRange: '*'
        direction: 'Outbound'
        priority: innerIndex + 100
        protocol: '*'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
      }
    }]
    defaultRules: length(subnet.value.restrictEgressTo) > 0 ? egressBlockRules : []
  }
}]

resource nsgs 'Microsoft.Network/networkSecurityGroups@2022-01-01' = [for (subnet, index) in items(subnets): {
  name: '${subnet.key}-nsg'
  location: location
  properties: nsgMap[index].outputs.nsgProperties
}]

output subnets array = [for (subnet, index) in items(subnets): {
  name: subnet.key
  properties: {
    addressPrefix: subnet.value.addressPrefix
    delegations: contains(subnet.value, 'delegation') ? [
      {
        name: '${subnet.key}-delegation'
        properties: {
          serviceName: subnet.value.delegation
        }
      }
    ] : []
    natGateway: contains(subnet.value, 'natGatewayId') ? {
      id: subnet.value.natGatewayId
    } : null
    networkSecurityGroup: contains(subnet.value, 'egressRules') &&  contains(subnet.value.egressRules, 'enabled') && subnet.value.egressRules.enabled ? {
      id: nsgs[index].id
    } : null
    routeTable: contains(subnet.value, 'udrId') ? {
      id: subnet.value.udrId
    } : null
    privateEndpointNetworkPolicies: contains(subnet.value, 'privateEndpointNetworkPolicies') ? subnet.value.privateEndpointNetworkPolicies : null
    privateLinkServiceNetworkPolicies: contains(subnet.value, 'privateLinkServiceNetworkPolicies') ? subnet.value.privateLinkServiceNetworkPolicies : null
    serviceEndpoints: contains(subnet.value, 'serviceEndpoints') ? subnet.value.serviceEndpoints : null
  }
}]
