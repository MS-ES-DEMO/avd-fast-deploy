
param location string = resourceGroup().location
param tags object
param environment string
param hubInfo object
param connectInfo object

resource remoteVnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: connectInfo.remoteVnetName
}

resource hub 'Microsoft.Network/virtualHubs@2020-06-01' existing = {
  name: hubInfo.name
}

resource hubDefaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-06-01' existing = {
  name: 'defaultRouteTable'
  parent: hub
}

resource hubNoneRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-06-01' existing = {
  name: 'noneRouteTable'
  parent: hub
}

resource hubVnetConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-06-01' = {
  name: connectInfo.name
  properties: {
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
    remoteVirtualNetwork: {
      id: remoteVnet.id
    }
    routingConfiguration: {
      associatedRouteTable: {
        id: hubDefaultRouteTable.id
      }
      propagatedRouteTables: {
        ids: [
          {
            id: hubNoneRouteTable.id
          }
        ]
        labels: [ 
          'none' 
        ]
      }
    }
  }
}

