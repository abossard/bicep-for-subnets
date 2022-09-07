@description('Array containing subnets to create within the Virtual Network. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?tabs=bicep#subnetpropertiesformat')
param subnets object

@description('Location for all resources')
param location string
@description('Tags that should be set on all resources')
param tags object = {}

param deploySubnetNames array = []
param deploySubet bool = false
param vnetName string
param egressBlockRules array = loadJsonContent('../nsg-egress-block-rules.json')

module nsgMap 'nsg-map.bicep' = [for (subnet, index) in items(subnets): if (empty(deploySubnetNames) || contains(deploySubnetNames, subnet.key)) {
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

resource nsgs 'Microsoft.Network/networkSecurityGroups@2022-01-01' = [for (subnet, index) in items(subnets): if (empty(deploySubnetNames) || contains(deploySubnetNames, subnet.key)) {
  name: '${subnet.key}-nsg'
  location: location
  tags: tags
  properties: nsgMap[index].outputs.nsgProperties
}]

module subnetMap './subnet-map.bicep' = [for (subnet, index) in items(subnets): if (empty(deploySubnetNames) || contains(deploySubnetNames, subnet.key)) {
  name: '${subnet.key}-subnetMap'
  params: {
    deploySubnet: deploySubet
    vnetName: vnetName
    name: subnet.key
    nsgId: nsgs[index].id
    subnet: subnet.value
  }
}]

var resultCount = empty(deploySubnetNames) ? length(items(subnets)) : length(deploySubnetNames)

output subnets array = [for index in range(0, resultCount): subnetMap[index].outputs.subnet]
