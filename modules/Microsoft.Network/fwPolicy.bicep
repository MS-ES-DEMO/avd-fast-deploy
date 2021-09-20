
param location string = resourceGroup().location
param tags object
param environment string
param logWorkspaceName string = 'wvd-${toLower(environment)}-workspace'
param monitoringResourceGroupName string
param fwPolicyInfo object 


resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logWorkspaceName
  scope: resourceGroup(monitoringResourceGroupName)
}

resource fwPolicy 'Microsoft.Network/firewallPolicies@2020-11-01' = {
  name: fwPolicyInfo.name
  location: location
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Alert'
    intrusionDetection: {
      mode: 'Alert'
    }
    snat: {
      privateRanges: fwPolicyInfo.snatRanges
    }
    insights: {
      isEnabled: true
      logAnalyticsResources: {
        defaultWorkspaceId: {
          id: logWorkspace.id
        }
      }
    }
  }
}

