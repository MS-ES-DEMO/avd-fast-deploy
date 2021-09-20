
param location string = resourceGroup().location
param tags object
param environment string
param name string = 'vwan-${toLower(environment)}-001}'

resource vwan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: false 
    office365LocalBreakoutCategory: 'None'
    type: 'Standard'
  }
}

output id string = vwan.id
