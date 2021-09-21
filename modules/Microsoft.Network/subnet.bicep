
param location string = resourceGroup().location
param tags object
param environment string
param snetInfo object


resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: '${snetInfo.vnetName}'
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' existing = {
  name: '${snetInfo.nsgName}'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${snetInfo.name}'
  parent: vnet
  properties: {
    addressPrefix: '${snetInfo.range}'
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}
