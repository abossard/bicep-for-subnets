@description('Array containing subnets to create within the Virtual Network. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?tabs=bicep#subnetpropertiesformat')
param subnets array = [
  {
    name: 'subnet1'
    addressPrefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'disabled'
    privateLinkServiceNetworkPolicies: 'disabled'
  }
]

output subnets array = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    delegations: contains(subnet, 'delegation') ? [
      {
        name: '${subnet.name}-delegation'
        properties: {
          serviceName: subnet.delegation
        }
      }
    ] : []
    natGateway: contains(subnet, 'natGatewayId') ? {
      id: subnet.natGatewayId
    } : null
    networkSecurityGroup: contains(subnet, 'nsgId') ? {
      id: subnet.nsgId
    } : null
    routeTable: contains(subnet, 'udrId') ? {
      id: subnet.udrId
    } : null
    privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
    serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : null
  }
}]
