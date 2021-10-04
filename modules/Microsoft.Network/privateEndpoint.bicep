
param location string = resourceGroup().location
param tags object
param name string
param vnetName string
param snetName string
param storageAccountName string
param blobPrivateDnsZoneName string


resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: snetName
  parent: vnet
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: blobPrivateDnsZoneName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          groupIds: [ 
            'blob' 
          ]
          privateLinkServiceId: storageAccount.id
        }
      }
    ]
    subnet: {
      id: snet.id
    }
  }
}

resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  name: format('{0}/{1}', name, 'blobPrivateDnsZoneGroup')
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
