param location string = resourceGroup().location
param tags object
param logWorkspaceName string 
param monitoringResourceGroupName string
param name string
param deployDiagnostic bool 
param maxSessionLimit int
param validationEnvironment bool = true

@description('Get string with $((get-date).ToUniversalTime().AddDays(1).ToString(\'yyyy-MM-ddTHH:mm:ss.fffffffZ\'))')
param tokenExpirationTime string = '7/31/2022 8:55:50 AM'



resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logWorkspaceName
  scope: resourceGroup(monitoringResourceGroupName)
}

resource hostpools 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' = {
  name: name
  location: location
  tags: tags
  properties: {
    friendlyName: name
    maxSessionLimit: maxSessionLimit
    loadBalancerType: 'BreadthFirst'
    validationEnvironment: validationEnvironment
    description: 'Created through the WVD extension'
    hostPoolType: 'Pooled'
    preferredAppGroupType: 'Desktop'
    personalDesktopAssignmentType: 'Automatic'
    customRdpProperty: 'audiocapturemode:i:0;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:0;redirectcomports:i:0;redirectprinters:i:0;redirectsmartcards:i:0;screen mode id:i:2;'
    ring: null
    startVMOnConnect: true
    registrationInfo: {
      expirationTime: tokenExpirationTime
      //token: null
      registrationTokenOperation: 'Update'
    }
    vmTemplate: ''
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = if (deployDiagnostic) {
  name: '${name}-diagsetting'
  scope: hostpools
  properties: {
    storageAccountId: null
    eventHubAuthorizationRuleId: null
    eventHubName: null
    workspaceId: logWorkspace.id
    logs: [
      {
        category: 'Checkpoint'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'Error'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'Management'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'Connection'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'HostRegistration'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
  }
}

output hostpoolToken string = hostpools.properties.registrationInfo.token