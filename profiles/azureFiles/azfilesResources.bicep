
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param tags object
param vnetName string 
param snetName string
param privateDnsZoneInfo array
param avdResourceGroupName string
param dnsResourceGroupName string
param storageAccountName string
param fileStorageAccountPrivateEndpointName string
param filePrivateDnsZoneName string



module privateDnsZone '../../modules/Microsoft.Network/privateDnsZone.bicep' = {
  name: 'privateDnsZoneResources_Deploy'
  params: {
    location: 'global'
    tags: tags
    name: privateDnsZoneInfo.name
  }
}

module avdVnetLink '../../modules/Microsoft.Network/vnetLink.bicep' = {
  name: 'avdVnetLinkResources_Deploy'
  dependsOn: [
    privateDnsZone
  ]
  scope: resourceGroup(avdResourceGroupName)
  params: {
    tags: tags
    name: '${privateDnsZoneInfo.vnetLinkPrefix}avd'
    vnetName: privateDnsZoneInfo.vnetName
    privateDnsZoneName: privateDnsZoneInfo.name
    vnetResourceGroupName: avdResourceGroupName
  }
}

module centralDnsVnetLink '../../modules/Microsoft.Network/vnetLink.bicep' = if (centralDnsExist) {
  name: 'centralDnsVnetLinkResources_Deploy'
  dependsOn: [
    privateDnsZone
  ]
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    tags: tags
    name: '${privateDnsZoneInfo.vnetLinkPrefix}centraldns'
    vnetName: vnetInfo.name
    privateDnsZoneName: privateDnsZoneInfo.name
    vnetResourceGroupName: dnsVnetResourceGroupName
  }
}

module storageAccountResources '../../modules/Microsoft.Storage/storageAccount.bicep' = {
  name: 'storageAccountResources_Deploy'
  params: {
    location: location
    tags: tags
    name: storageAccountName
  }
}

module filePrivateEndpointResources '../../modules/Microsoft.Network/storagePrivateEndpoint.bicep' = {
  name: 'filePrivateEndpointResources_Deploy'
  dependsOn: [
    storageAccountResources
  ]
  params: {
    location: location
    tags: tags
    name: fileStorageAccountPrivateEndpointName
    vnetName: vnetName
    snetName: snetName
    storageAccountName: storageAccountName
    privateDnsZoneName: filePrivateDnsZoneName
    groupIds: 'file'
    addsDnsResourceGroupName: dnsResourceGroupName
  }
}




