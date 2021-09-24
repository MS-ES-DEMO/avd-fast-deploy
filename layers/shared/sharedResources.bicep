
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param tags object
param vnetInfo object 
param nsgInfo object
param snetInfo object = {}
param nicName string
param deployCustomDns bool
param commonResourceGroupName string
param vmName string
param vmSize string
@secure()
param vmAdminUsername string
@secure()
param vmAdminPassword string



module vnetResources '../../modules/Microsoft.Network/vnet.bicep' = {
  name: 'vnetResources_Deploy'
  params: {
    location: location
    tags: tags
    vnetInfo: vnetInfo
    deployCustomDns: deployCustomDns
    dnsNicName: nicName
    commonResourceGroupName: commonResourceGroupName
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

module subnetResources '../../modules/Microsoft.Network/subnet.bicep' = {
  name: 'subnetResources_Deploy'
  dependsOn: [
    vnetResources
    nsgResources
    nsgInboundRulesResources
  ]
  params: {
    snetInfo: snetInfo
    nsgName: nsgInfo.name
    vnetInfo: vnetInfo
  }
}

module nicResources '../../modules/Microsoft.Network/nic.bicep' = {
  name: 'nicResources_Deploy'
  params: {
    tags: tags
    name: nicName
    snetName: snetInfo.name
    nsgName: nsgInfo.name
  }
}


module vmResources '../../modules/Microsoft.Compute/vm.bicep' = {
  name: 'vmResources_Deploy'
  params: {
    tags: tags
    name: vmName
    vmSize: vmSize
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    nicName: nicName
  }
}


