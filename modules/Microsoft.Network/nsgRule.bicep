
param location string = resourceGroup().location
param tags object
param environment string
param name string
param rule object
param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' existing = {
  name: nsgName
}

resource nsgRule 'Microsoft.Network/networkSecurityGroups/securityRules@2020-06-01' = {
  name: name
  parent: nsg
  properties: rule
}
