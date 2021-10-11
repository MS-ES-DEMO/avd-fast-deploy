
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param tags object
param vnetInfo object 
param snetsInfo array
param privateDnsZonesInfo array
param deployCustomDns bool = true
param dnsNicName string
param dnsResourceGroupName string
param storageAccountName string
param fileStorageAccountPrivateEndpointName string
param filePrivateDnsZoneName string



module vnetResources '../../modules/Microsoft.Network/vnet.bicep' = {
  name: 'vnetResources_Deploy'
  params: {
    location: location
    tags: tags
    vnetInfo: vnetInfo
    deployCustomDns: deployCustomDns
    dnsNicName: dnsNicName
    dnsResourceGroupName: dnsResourceGroupName
    snetsInfo: snetsInfo
  }
}

module vnetLinks '../../modules/Microsoft.Network/vnetLink.bicep' = [ for (privateDnsZoneInfo, i) in privateDnsZonesInfo : {
  name: 'awvdVnetLinksResources_Deploy${i}'
  scope: resourceGroup(dnsResourceGroupName)
  dependsOn: [
    vnetResources
  ]
  params: {
    tags: tags
    name: '${privateDnsZoneInfo.vnetLinkName}awvd'
    vnetName: vnetInfo.name
    privateDnsZoneName: privateDnsZoneInfo.name
    vnetResourceGroupName: resourceGroup().name
  }
}]

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
    vnetResources
    storageAccountResources
  ]
  params: {
    location: location
    tags: tags
    name: fileStorageAccountPrivateEndpointName
    vnetName: vnetInfo.name
    snetName: snetsInfo[0].name
    storageAccountName: storageAccountName
    privateDnsZoneName: filePrivateDnsZoneName
    groupIds: 'file'
    dnsResourceGroupName: dnsResourceGroupName
  }
}




