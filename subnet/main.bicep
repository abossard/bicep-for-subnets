//
// MAIN deployment for a specific subnets
//
//
@description('VNET where this module will add the subnets to')
param vnetName string = uniqueString(resourceGroup().id)

@description('List of subnets to be added to the VNET, it defaults to the subnets.json')
param subnets object = loadJsonContent('../subnets.json')

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Which subnets of the supplied subnets should be added. Default: last')
param deploySubnetNames array = ['trial-7', 'workstation-3456']

// there this module is creating the NSGs as well as the subnets
module subnetNsgRules '../subnet/subnet-nsg-rules.bicep' = {
  name: 'subnetNsgRules'
  params: {
    deploySubet: true // this is important since Bicep is inable to handle conditinal loops in module output 
    vnetName: vnetName
    location: location
    subnets: subnets
    deploySubnetNames: deploySubnetNames
  }
}
