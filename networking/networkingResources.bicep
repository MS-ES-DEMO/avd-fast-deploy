
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param environment string
param tags object
param vnetsInfo array 
param vwanName string = 'vwan-${toLower(environment)}-001}'
param hubInfo object 
param monitoringResourceGroupName string
param logWorkspaceName string
param fwPolicyInfo object 
param appRuleCollectionGroupName string = 'fwapprulegroup-${toLower(environment)}'
param appRulesInfo object 
param networkRuleCollectionGroupName string = 'fwnetrulegroup-${toLower(environment)}'
param networkRulesInfo object 
param fwPublicIpName string
param firewallName string
param destinationAddresses array
param hubVnetConnectionsInfo array



module vnetResources '../modules/Microsoft.Network/vnet.bicep' = [ for (vnetInfo, i) in vnetsInfo: {
  name: 'vnetResources_Deploy${i}'
  params: {
    location: location
    environment: environment
    tags: tags
    vnetInfo: vnetInfo
  }
}]

module vwanResources '../modules/Microsoft.Network/vwan.bicep' = {
  name: 'vwanResources_Deploy'
  params: {
    location: location
    environment: environment
    tags: tags 
    name: vwanName
  }
}

module hubResources '../modules/Microsoft.Network/hub.bicep' = {
  name: 'hubResources_Deploy'
  params: {
    location: location
    environment: environment
    tags: tags
    hubInfo: hubInfo
    vwanId: vwanResources.outputs.id
  }
}

module fwPolicyResources '../modules/Microsoft.Network/fwPolicy.bicep' = {
  name: 'fwPolicyResources_Deploy'
  params: {
    location: location
    environment: environment
    tags: tags
    monitoringResourceGroupName: monitoringResourceGroupName
    logWorkspaceName: logWorkspaceName
    fwPolicyInfo: fwPolicyInfo
  }
}

module fwAppRulesResources '../modules/Microsoft.Network/fwRules.bicep' = {
  name: 'fwAppRulesResources_Deploy'
  params: {
    location: location
    environment: environment
    tags: tags
    fwPolicyName: fwPolicyInfo.name
    ruleCollectionGroupName: appRuleCollectionGroupName
    rulesInfo: appRulesInfo
  }
}

module fwNetworkRulesResources '../modules/Microsoft.Network/fwRules.bicep' = {
  name: 'fwNetworkRulesResources_Deploy'
  dependsOn: [
    fwAppRulesResources
  ]
  params: {
    location: location
    environment: environment
    tags: tags
    fwPolicyName: fwPolicyInfo.name
    ruleCollectionGroupName: networkRuleCollectionGroupName
    rulesInfo: networkRulesInfo
  }
}

module fwPublicIpResources '../modules/Microsoft.Network/publicIp.bicep' = {
  name: 'fwPublicIpResources_Deploy'
  params: {
    location: location
    environment: environment
    tags: tags
    name: fwPublicIpName
  }

}

module firewallResources '../modules/Microsoft.Network/firewall.bicep' = {
  name: 'firewallResources_Deploy'
  dependsOn: [
    fwPublicIpResources
    fwPolicyResources
    fwAppRulesResources
    fwNetworkRulesResources
  ]
  params: {
    location: location
    environment: environment
    tags: tags
    name: firewallName
    monitoringResourceGroupName: monitoringResourceGroupName
    fwPolicyInfo: fwPolicyInfo
    hubName: hubInfo.name
    fwPublicIpName: fwPublicIpName
  }
}

module hubRouteTableResources '../modules/Microsoft.Network/hubRouteTable.bicep' = {
  name: 'hubRouteTableResources_Deploy'
  dependsOn: [
    hubResources
    firewallResources
  ]
  params: {
    location: location
    environment: environment
    tags: tags
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
    location: location
    environment: environment
    tags: tags
    hubInfo: hubInfo
    connectInfo: connectInfo
  }
}]


