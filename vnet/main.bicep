//
// MAIN file to deploy a VNET with all it's subnets and NSG's
//
//

@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {
  Environment: 'Production'
  Application: 'PowerBIEmbedded'
}

@description('The name of the resource group that will be created.')
param resourceGroupName string = 'rg-vnet-test'

@description('The subnets to be deployed, can be a JSON object or it takes the default: subnets.json')
param subnets object = loadJsonContent('../subnets.json')

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

var vnetName = uniqueString(rg.id)

// this module is creating the NSGs and returning an array of the subnet properties
module subnetNsgRulesMap '../subnet/subnet-nsg-rules.bicep' = {
  name: 'subnetNsgRulesMap'
  scope: rg
  params: {
    vnetName: vnetName
    subnets: subnets
    location: location
    tags: tags
  }
}

// this creates the VNET and uses the output of the previous module to create the subnets
module stg './vnet.bicep' = {
  name: 'vnetDeployment'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    name: vnetName
    location: rg.location
    tags: tags
    subnets: subnetNsgRulesMap.outputs.subnets
  }
}
