
param location string = resourceGroup().location
param tags object
param environment string
param fwPolicyName string = 'fwpolicy-${toLower(environment)}-001'
param ruleCollectionGroupName string = 'fwapprulegroup-${toLower(environment)}'
param rulesInfo object

resource fwPolicy 'Microsoft.Network/firewallPolicies@2020-11-01' existing = {
  name: fwPolicyName
}

resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  parent: fwPolicy
  name: ruleCollectionGroupName
  properties: rulesInfo
}
