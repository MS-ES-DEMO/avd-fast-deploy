
param location string = resourceGroup().location
param tags object
param environment string
param vnetInfo object = {
    name: 'adds'
    range: '10.0.1.0/24'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetInfo.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetInfo.range
      ]
    }
  }
}
