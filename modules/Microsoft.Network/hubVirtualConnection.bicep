
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
param connectionInfo object = {
  hubName: 'hub-${toLower(environment)}-001'
  remoteVnetId: '10.0.0.0/24'
}
@description('VWAN Id')
param vwanId string


resource hub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: hubInfo.name
  location: location
  tags: tags
  properties: {
    addressPrefix: hubInfo.range
    allowBranchToBranchTraffic: false 
    virtualWan: {
      id: vwanId
    }
  }
}

