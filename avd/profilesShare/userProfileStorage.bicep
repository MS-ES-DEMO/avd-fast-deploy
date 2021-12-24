
param location string = resourceGroup().location
param tags object
param name string
param fileShareName string
param vnetName string
param snetName string
param privateEndpointName string
param privateDnsZoneResourceGroupName string
param privateDnsZoneName string


resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  name: snetName
}

module storageAccount '../../modules/Microsoft.Storage/storageAccount.bicep' = {
  name: 'storageAccountForUserProfiles_Deploy'
  params: {
    name: name
    location: location
    tags: tags
  }
}

module fileShare '../../modules/Microsoft.Storage/fileShare.bicep' = {
  name: 'storageAccountForUserProfilesFileShare_Deploy'
  dependsOn: [
    storageAccount
  ]
  params: {
    name: fileShareName
    storageAccountName: name
  }
}

module privateEndpoint '../../modules/Microsoft.Network/storagePrivateEndpoint.bicep' = {
  name:'privateEndpointStorageAccountForUserProfilesFileShare_Deploy'
  dependsOn: [
    storageAccount
  ]
  params: {
    name: privateEndpointName
    location: location
    tags: tags
    storageAccountName: name
    vnetName: vnet.name
    snetName: snet.name
    privateDnsZoneName: privateDnsZoneName
    groupIds: 'file'
    addsDnsResourceGroupName: privateDnsZoneResourceGroupName
  }
}
