//
// Welcome to the juicy part. 
// This file is is creating the NGS's and adding them to the subnets
//
//

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

// this is how you can do a nested loop with bicep:
// - it loops over the subnets that are part of the deployment
// - for each subnet it loops over the egress block rules and then, looks up the addressPrefix from the 
//   target subnet
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

// Since we need the NSG id, there's no other way than to actually create it.
resource nsgs 'Microsoft.Network/networkSecurityGroups@2022-01-01' = [for (subnet, index) in items(subnets): if (empty(deploySubnetNames) || contains(deploySubnetNames, subnet.key)) {
  name: '${subnet.key}-nsg'
  location: location
  tags: tags
  properties: nsgMap[index].outputs.nsgProperties
}]

// loop with conditionals can essentially only be used in resources and modules
// also the module output is skewed due to the conditional, so the module will always return
// and yeah, the order of properties in javascript is not garanteed, so yeah
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
