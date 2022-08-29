param vnetName string = uniqueString(resourceGroup().id)
param deployOnlyLast bool = true

var lastSubnet = loadJsonContent('../subnets.json', '$[-1:]')
var allSubnets = loadJsonContent('../subnets.json')

module subnetMap '../subnet/subnet-map.bicep' = {
  name: 'subnetMap'
  params: {
    subnets: deployOnlyLast ? [lastSubnet]: allSubnets
  }
}


module stg './subnet.bicep' = {
  name: 'subnetDeployment'
  params: {
    vnetName: vnetName
    subnets: subnetMap.outputs.subnets
  }
}
