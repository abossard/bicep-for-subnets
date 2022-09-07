param vnetName string = uniqueString(resourceGroup().id)

param subnets object = loadJsonContent('../subnets.json')
param location string = resourceGroup().location
param deployIndexes array = [length(items(subnets)) -1]

module subnetMap '../subnet/subnet-map.bicep' = {
  name: 'subnetMap'
  params: {
    location: location
    subnets: subnets
  }
}


module stg './subnet.bicep' = [for subnetIndex in deployIndexes: {
  name: 'subnetDeployment-${subnetIndex}'
  params: {
    vnetName: vnetName
    subnets: [subnetMap.outputs.subnets[subnetIndex]]
  }
}]
