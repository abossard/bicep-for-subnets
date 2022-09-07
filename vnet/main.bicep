param location string = 'westeurope'
param tags object = {
  Environment: 'Production'
  Application: 'PowerBIEmbedded'
}
param subnets object = loadJsonContent('../subnets.json')

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-vnet-test'
  location: location
  tags: tags
}

module subnetMap '../subnet/subnet-map.bicep' = {
  name: 'subnetMap'
  scope: rg
  params: {
    subnets: subnets
    location: location
  }
}


module stg './vnet.bicep' = {
  name: 'vnetDeployment'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    name: uniqueString(rg.id)
    location: rg.location
    tags: tags
    subnets: subnetMap.outputs.subnets
  }
}
