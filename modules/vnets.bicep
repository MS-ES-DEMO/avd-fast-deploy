
@description('Location of the resources')
param location string = resourceGroup().location
@description('Project Tags')
param tags object
@description('Environment: Dev,Test,PreProd,Uat,Prod,ProdDr.')
@allowed([
  'Dev'
  'Test'
  'PreProd'
  'Uat'
  'Prod'
  'ProdDr'
])
param environment string
@description('Name and range for vNets')
param vNetsInfo array = [
  {
    name: 'vnet-hub'
    range: '10.0.0.0/24'
  }
  {
    name: 'vnet-addsanddns'
    range: '10.0.1.0/24'
  }
  {
    name: 'vnet-wvd'
    range: '10.0.2.0/24'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = [ for vnetInfo in vNetsInfo: {
  name: '${vnetInfo.name}'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetInfo.range}'
      ]
    }
  }
}]
