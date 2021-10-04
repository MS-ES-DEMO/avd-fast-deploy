
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
  name: 'vnetLinksResources_Deploy${i}'
  dependsOn: [
    vnetResources
  ]
  params: {
    tags: tags
    name: privateDnsZoneInfo.vnetLinkName
    vnetName: vnetInfo.name
    privateDnsZoneName: privateDnsZoneInfo.name
  }
}]




