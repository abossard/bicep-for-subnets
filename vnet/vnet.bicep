param tags object
@description('Virtual network name')
param name string = uniqueString(resourceGroup().id)

@description('Virtual network location')
param location string = resourceGroup().location

@description('Array containing virtual network address space(s)')
param vnetAddressSpace array = [
  '10.0.0.0/16'
]

@description('Array containing DNS Servers')
param dnsServers array = []

@description('Array containing subnets to create within the Virtual Network. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets?tabs=bicep#subnetpropertiesformat')
param subnets array = []

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressSpace
    }
    dhcpOptions: empty(dnsServers) ? null : {
      dnsServers: dnsServers
    }
    subnets: subnets
  }
}
