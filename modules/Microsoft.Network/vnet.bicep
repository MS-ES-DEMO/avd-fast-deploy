
param location string = resourceGroup().location
param tags object
param vnetInfo object = {
    name: 'adds'
    range: '10.0.1.0/24'
}
param dnsNicName string
param sharedResourceGroupName string
param deployCustomDns bool

resource dnsNic 'Microsoft.Network/networkInterfaces@2021-02-01' existing = if (deployCustomDns) {
  name: dnsNicName
  scope: resourceGroup(sharedResourceGroupName)
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
    dhcpOptions: {
      dnsServers: (deployCustomDns) ? [
        dnsNic.properties.ipConfigurations[0].properties.privateIPAddress
        '168.63.129.16'
      ] : json('null')
    }
  }
}
