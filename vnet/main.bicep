@description('The default location that is used everywhere.')
param location string = 'westeurope'

@description('Tags that should be added to all resources')
param tags object = {
  Environment: 'Production'
  Application: 'PowerBIEmbedded'
}

@description('The subnets to be deployed, can be a JSON object or it takes the default: subnets.json')
param subnets object = loadJsonContent('../subnets.json')

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-vnet-test'
  location: location
  tags: tags
}

var vnetName = uniqueString(rg.id)
module subnetMap '../subnet/subnet-nsg-rules.bicep' = {
  name: 'subnetMap'
  scope: rg
  params: {
    vnetName: vnetName
    subnets: subnets
    location: location
    tags: tags
  }
}


module stg './vnet.bicep' = {
  name: 'vnetDeployment'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    name: vnetName
    location: rg.location
    tags: tags
    subnets: subnetMap.outputs.subnets
  }
}
