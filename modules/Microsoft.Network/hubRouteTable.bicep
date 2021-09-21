
param location string = resourceGroup().location
param tags object
param environment string
param hubInfo object 
param firewallName string
param destinations array

resource hub 'Microsoft.Network/virtualHubs@2020-06-01' existing = {
  name: hubInfo.name
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-06-01' existing = {
  name: firewallName
}

resource hubNoneRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-06-01' = {
  name: 'noneRouteTable'
  parent: hub
  properties: {
    labels: [ 
      'none' 
    ]
    routes: []
  }
}

resource hubDefaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-06-01' = {
  name: 'defaultRouteTable'
  parent: hub
  properties: {
    labels: [ 
      'default' 
    ]
    routes: [
      {
        destinations: destinations
        destinationType: 'CIDR'
        name: 'east-west/north-south traffic'
        nextHop: firewall.id
        nextHopType: 'ResourceId'
      }
    ]
  }
}

