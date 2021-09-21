
param location string = resourceGroup().location
param tags object
param environment string
param logWorkspaceName string = 'wvd-${toLower(environment)}-workspace'
param monitoringResourceGroupName string
param fwPolicyInfo object 
param name string
param hubName string
param fwPublicIpName string


resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logWorkspaceName
  scope: resourceGroup(monitoringResourceGroupName)
}

resource fwPolicy 'Microsoft.Network/firewallPolicies@2020-11-01' existing = {
  name: fwPolicyInfo.name
}

resource hub 'Microsoft.Network/virtualHubs@2021-02-01' existing = {
  name: hubName
}

resource fwPublicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' existing = {
  name: fwPublicIpName
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: name
  location: location
  tags: tags
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Premium'
    }
    //threatIntelMode: 'Alert'
    additionalProperties: {}
    hubIPAddresses: {
      publicIPs: {
        addresses: [
          {
            address: fwPublicIp.properties.ipAddress
          }
        ]
        count: 1
      }
    }
    networkRuleCollections: []
    applicationRuleCollections: []
    natRuleCollections: []
    virtualHub: {
      id: hub.id
    }
    firewallPolicy: {
      id: fwPolicy.id
    }
  }
}

resource firewallDiagnostics 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = {
  name: '${name}-${toLower(environment)}-diagsetting'
  scope: firewall
  properties: {
    name: '${name}-${toLower(environment)}-diagsetting'
    storageAccountId: null
    eventHubAuthorizationRuleId: null
    eventHubName: null
    workspaceId: logWorkspace.id
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
        retentionPolicy: {
          days: 10
          enabled: false
        }
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
        retentionPolicy: {
          days: 10
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

