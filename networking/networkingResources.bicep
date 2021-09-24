
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param tags object
param securityResourceGroupName string
param vnetsInfo array 
param vwanName string 
param hubInfo object 
param monitoringResourceGroupName string
param logWorkspaceName string
param fwPolicyInfo object 
param appRuleCollectionGroupName string
param appRulesInfo object 
param networkRuleCollectionGroupName string
param networkRulesInfo object 
param fwPublicIpName string
param firewallName string
param destinationAddresses array
param hubVnetConnectionsInfo array
param dnsSnetInfo object
param jumpSnetInfo object
param privateDnsZonesInfo array



module vnetResources '../modules/Microsoft.Network/vnet.bicep' = [ for (vnetInfo, i) in vnetsInfo: {
  name: 'vnetResources_Deploy${i}'
  params: {
    location: location
    tags: tags
    vnetInfo: vnetInfo
  }
}]

module vwanResources '../modules/Microsoft.Network/vwan.bicep' = {
  name: 'vwanResources_Deploy'
  params: {
    location: location
    tags: tags 
    name: vwanName
  }
}

module hubResources '../modules/Microsoft.Network/hub.bicep' = {
  name: 'hubResources_Deploy'
  dependsOn: [
    vwanResources
  ]
  params: {
    location: location
    tags: tags
    hubInfo: hubInfo
    vwanId: vwanResources.outputs.id
  }
}

module fwPolicyResources '../modules/Microsoft.Network/fwPolicy.bicep' = {
  name: 'fwPolicyResources_Deploy'
  scope: resourceGroup(securityResourceGroupName)
  params: {
    location: location
    tags: tags
    monitoringResourceGroupName: monitoringResourceGroupName
    logWorkspaceName: logWorkspaceName
    fwPolicyInfo: fwPolicyInfo
  }
}

module fwAppRulesResources '../modules/Microsoft.Network/fwRules.bicep' = {
  name: 'fwAppRulesResources_Deploy'
  scope: resourceGroup(securityResourceGroupName)
  dependsOn: [
    fwPolicyResources
  ]
  params: {
    fwPolicyName: fwPolicyInfo.name
    ruleCollectionGroupName: appRuleCollectionGroupName
    rulesInfo: appRulesInfo
  }
}

module fwNetworkRulesResources '../modules/Microsoft.Network/fwRules.bicep' = {
  name: 'fwNetworkRulesResources_Deploy'
  scope: resourceGroup(securityResourceGroupName)
  dependsOn: [
    fwPolicyResources
    fwAppRulesResources
  ]
  params: {
    fwPolicyName: fwPolicyInfo.name
    ruleCollectionGroupName: networkRuleCollectionGroupName
    rulesInfo: networkRulesInfo
  }
}

module fwPublicIpResources '../modules/Microsoft.Network/publicIp.bicep' = {
  name: 'fwPublicIpResources_Deploy'
  scope: resourceGroup(securityResourceGroupName)
  params: {
    location: location
    tags: tags
    name: fwPublicIpName
  }

}

module firewallResources '../modules/Microsoft.Network/firewall.bicep' = {
  name: 'firewallResources_Deploy'
  scope: resourceGroup(securityResourceGroupName)
  dependsOn: [
    fwPublicIpResources
    fwPolicyResources
    fwAppRulesResources
    fwNetworkRulesResources
    hubResources
  ]
  params: {
    location: location
    tags: tags
    name: firewallName
    monitoringResourceGroupName: monitoringResourceGroupName
    fwPolicyInfo: fwPolicyInfo
    hubName: hubInfo.name
    fwPublicIpName: fwPublicIpName
    logWorkspaceName: logWorkspaceName
  }
}

module hubRouteTableResources '../modules/Microsoft.Network/hubRouteTable.bicep' = {
  name: 'hubRouteTableResources_Deploy'
  dependsOn: [
    hubResources
    firewallResources
  ]
  params: {
    hubInfo: hubInfo
    firewallName: firewallName
    destinations: destinationAddresses
  }
}

module hubVirtualConnectionResources '../modules/Microsoft.Network/hubVnetConnection.bicep' = [ for (connectInfo, i) in hubVnetConnectionsInfo: {
  name: 'hubVirtualConnectionResources_Deploy${i}'
  dependsOn: [
    vnetResources
    hubResources
    hubRouteTableResources
  ]
  params: {
    hubInfo: hubInfo
    connectInfo: connectInfo
  }
}]

module nsgAddsSubnetResources '../modules/Microsoft.Network/nsg.bicep' = {
  name: 'nsgAddsSubnetResources_Deploy'
  params: {
    location: location
    tags: tags
    name: ''
    snetInfo: dnsSnetInfo
  }
}

module nsgAddsSubnetInboundRulesResources '../modules/Microsoft.Network/nsgRule.bicep' = [ for (ruleInfo, i) in dnsSnetInfo.nsgInboundRules: {
  name: 'nsgAddsSubnetInboundRulesResources_Deploy${i}'
  dependsOn: [
    nsgAddsSubnetResources 
  ]
  params: {
    name: ruleInfo.name
    rule: ruleInfo.rule
    nsgName: dnsSnetInfo.nsgName
  }
}]

module subnetAddsResources '../modules/Microsoft.Network/subnet.bicep' = {
  name: 'subnetAddsResources'
  dependsOn: [
    vnetResources
    nsgAddsSubnetResources
    nsgAddsSubnetInboundRulesResources
  ]
  params: {
    snetInfo: dnsSnetInfo
  }
}


module nsgJumpSubnetResources '../modules/Microsoft.Network/nsg.bicep' = {
  name: 'nsgJumpSubnetResources_Deploy'
  params: {
    location: location
    tags: tags
    name: ''
    snetInfo: jumpSnetInfo
  }
}

module subnetJumpResources '../modules/Microsoft.Network/subnet.bicep' = {
  name: 'subnetJumpResources_Deploy'
  dependsOn: [
    vnetResources
    nsgJumpSubnetResources
  ]
  params: {
    snetInfo: jumpSnetInfo
  }
}

module privateDnsZones '../modules/Microsoft.Network/privateDnsZone.bicep' = [ for (privateDnsZoneInfo, i) in privateDnsZonesInfo : {
  name: 'privateDnsZonesResources_Deploy${i}'
  dependsOn: [
    vnetResources
  ]
  params: {
    location: 'global'
    tags: tags
    name: privateDnsZoneInfo.name
  }
}]

module vnetLinks '../modules/Microsoft.Network/vnetLink.bicep' = [ for (privateDnsZoneInfo, i) in privateDnsZonesInfo : {
  name: 'vnetLinksResources_Deploy${i}'
  dependsOn: [
    vnetResources
  ]
  params: {
    tags: tags
    name: privateDnsZoneInfo.vnetLinkName
    vnetName: privateDnsZoneInfo.vnetName
  }
}]


