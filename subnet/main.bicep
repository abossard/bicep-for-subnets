param vnetName string = uniqueString(resourceGroup().id)

param subnets object = loadJsonContent('../subnets.json')
param location string = resourceGroup().location
param subnetsToDeploy array = [
  'workstation-46'
]
module subnetMap '../subnet/subnet-map.bicep' = {
  name: 'subnetMap'
  params: {
    location: location
    subnets: subnets
  }
}


module stg './subnet.bicep' = [for subnet in subnetsToDeploy: {
  name: 'subnetDeployment-${subnet}'
  params: {
    vnetName: vnetName
    subnets: [subnetMap.outputs.subnets[subnet]]
  }
}]
