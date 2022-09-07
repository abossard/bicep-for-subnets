@description('VNET where this module will add the subnets to')
param vnetName string = uniqueString(resourceGroup().id)

@description('List of subnets to be added to the VNET, it defaults to the subnets.json')
param subnets object = loadJsonContent('../subnets.json')

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Which JSON indexes of the supplied subnets should be added. Default: last')
param deploySubnetNames array = ['trial-7', 'workstation-3456']

module subnetNsgRules '../subnet/subnet-nsg-rules.bicep' = {
  name: 'subnetNsgRules'
  params: {
    deploySubet: true
    vnetName: vnetName
    location: location
    subnets: subnets
    deploySubnetNames: deploySubnetNames
  }
}
