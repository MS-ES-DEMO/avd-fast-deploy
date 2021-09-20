
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
@description('Name and range for ADDS subnet')
param subnetAwvdInfo array = [
  {
    name: 'operations'
    range: '10.0.2.0/27'
  }
  {
    name: 'datascientist'
    range: '10.0.2.0/27'
  }
]


resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: 'vnet-${toLower(environment)}-${subnetAddsInfo.name}'
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-06-01' existing = {
  name: 'nsg-${toLower(environment)}-snet-${subnetAddsInfo.name}'
}

resource routeTable 'Microsoft.Network/routeTables@2020-06-01' existing = {
  name: 'udr-${toLower(environment)}-snet-${subnetAddsInfo.name}'
}

resource subnetAdds 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'snet-${toLower(environment)}-${subnetAddsInfo.name}'
  parent: vnet
  properties: {
    addressPrefix: '${subnetAddsInfo.range}'
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    routeTable: {
      id: routeTable.id
    }
    delegations: []
  }
}

resource subnetAwvd 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'snet-${toLower(environment)}-${subnetAddsInfo.name}'
  parent: vnet
  properties: {
    addressPrefix: '${subnetAddsInfo.range}'
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    routeTable: {
      id: routeTable.id
    }
    delegations: []
  }
}
