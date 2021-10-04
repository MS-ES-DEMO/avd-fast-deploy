
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param tags object
param vnetInfo object 
param nsgInfo object
param snetsInfo array
param privateDnsZonesInfo array
param nicName string
param deployCustomDns bool = true
param dnsNicName string
param dnsResourceGroupName string
param vmName string
param vmSize string
@secure()
param vmAdminUsername string
@secure()
param vmAdminPassword string
param storageAccountName string
param blobStorageAccountPrivateEndpointName string
param blobPrivateDnsZoneName string


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


module nsgResources '../../modules/Microsoft.Network/nsg.bicep' = {
  name: 'nsgResources_Deploy'
  params: {
    location: location
    tags: tags
    name: nsgInfo.name
  }
}

module nsgInboundRulesResources '../../modules/Microsoft.Network/nsgRule.bicep' = [ for (ruleInfo, i) in nsgInfo.inboundRules: {
  name: 'nsgInboundRulesResources_Deploy${i}'
  dependsOn: [
    nsgResources 
  ]
  params: {
    name: ruleInfo.name
    rule: ruleInfo.rule
    nsgName: nsgInfo.name
  }
}]

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

module nicResources '../../modules/Microsoft.Network/nic.bicep' = {
  name: 'nicResources_Deploy'
  dependsOn: [
    vnetResources
  ]
  params: {
    tags: tags
    name: nicName
    vnetName: vnetInfo.name
    snetName: snetsInfo[0].name
    nsgName: nsgInfo.name
  }
}

module vmResources '../../modules/Microsoft.Compute/vm.bicep' = {
  name: 'vmResources_Deploy'
  dependsOn: [
    nicResources
  ]
  params: {
    tags: tags
    name: vmName
    vmSize: vmSize
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    nicName: nicName
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

module blobPrivateEndpointResources '../../modules/Microsoft.Network/privateEndpoint.bicep' = {
  name: 'privateEndpointResources_Deploy'
  dependsOn: [
    vnetResources
    storageAccountResources
  ]
  params: {
    location: location
    tags: tags
    name: blobStorageAccountPrivateEndpointName
    vnetName: vnetInfo.name
    snetName: snetsInfo[1].name
    storageAccountName: storageAccountName
    blobPrivateDnsZoneName: blobPrivateDnsZoneName
  }
}




