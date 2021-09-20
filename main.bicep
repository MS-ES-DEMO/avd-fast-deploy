targetScope = 'subscription'

// TODO: verify the required parameters

// Global Parameters
@description('Location of the resources')
@allowed([
  'northeurope'
  'westeurope'
])
param location string
@description('Environment: Dev,Test,PreProd,Uat,Prod,ProdDr.')
@allowed([
  'Dev'
  'Test'
  'PreProd'
  'Uat'
  'Prod'
  'ProdDr'
])
param environment string

// monitoringResources
@description('Name for Monitoring RG')
param monitoringResourceGroupName string
@description('Deploy Log Analytics Workspace?')
param deployLogWorkspace bool
@description('Name for existing Log Analytics Workspace')
param existingLogWorkspaceName string = ''


// networkingResources
@description('Name for Networking RG')
param networkingResourceGroupName string
@description('Name and range for vNets')
param vnetsInfo array = [
  {
    name: 'vnet-${toLower(environment)}-hub'
    range: '10.0.0.0/24'
  }
  {
    name: 'vnet-${toLower(environment)}-adds'
    range: '10.0.1.0/24'
  }
  {
    name: 'vnet-${toLower(environment)}-awvd'
    range: '10.0.2.0/24'
  }
]
@description('Name for VWAN')
param vwanName string = 'vwan-${toLower(environment)}-001}'
@description('Name and range for Hub')
param hubInfo object = {
    name: 'hub-${toLower(environment)}-001'
    range: '10.0.0.0/24'
}

@description('Name and snat ranges for fw policy')
param fwPolicyInfo object = {
  name: 'fwpolicy-${toLower(environment)}-001'
  snatRanges: [
    '129.35.65.13'
    '82.132.128.0/17'
    '158.230.0.0/18'
    '158.230.64.0/19'
    '158.230.104.0/21'
    '158.230.112.0/20'
    '158.230.128.0/18'
    '193.35.171.0/24'
    '193.35.173.0/25'
    '193.113.120.0/25'
    '193.113.121.128/25'
    '193.113.160.0/25'
    '193.113.160.128/26'
    '193.113.200.128/25'
    '193.113.228.0/24'
    '193.132.40.0/24'
    '216.239.204.0/26'
    '216.239.204.192/26'
    '216.239.205.192/26'
    '216.239.206.0/25'
    '10.0.0.0/8'
    '172.16.0.0/12'
    '192.168.0.0/16'
    '100.64.0.0/10'
  ]
}

@description('Name for application rule collection group')
param appRuleCollectionGroupName string = 'fwapprulegroup-${toLower(environment)}'
@description('Rule Collection Info')
param appRulesInfo object = {
  priority: 300
  ruleCollections: [
    {
      ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      action: {
        type: 'Allow'
      }
      name: 'AzureMonitorRuleCollection'
      priority: 100
      rules: [
        {
          ruleType: 'ApplicationRule'
          name: 'Allow-AzureMonitor'
          protocols: [
            {
              protocolType: 'Https'
              port: 443
            }
          ]
          fqdnTags: []
          webCategories: []
          targetFqdns: [
            '*.monitor.core.windows.net'
          ]
          targetUrls: []
          terminateTLS: false
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: []
          sourceIpGroups: []
        }
      ]
    }
  ]
}
@description('Name for application rule collection group')
param networkRuleCollectionGroupName string = 'fwnetrulegroup-${toLower(environment)}'
@description('Rule Collection Info')
param networkRulesInfo object = {
  priority: 200
  ruleCollections: [
    {
      ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      name: 'Windows'
      action: {
        type: 'Allow'
      }
      priority: 210
      rules: [
        {
          ruleType: 'NetworkRule'
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            '172.17.66.38/32'
            '172.17.206.254/32'
            '172.17.57.219/32'
          ]
          destinationPorts: [
            '1688'
          ]
          ipProtocols: [
            'TCP'
          ]
          name: 'Windows-Software-Activation'
          destinationIpGroups: []
          destinationFqdns: []
          sourceIpGroups: []
        }
      ]
    }
  ]
}
@description('Name for Azure Firewall')
param firewallName string = 'azfw-${toLower(environment)}'
@description('Name for Azure Firewall public ip')
param fwPublicIpName string = 'pip-${toLower(environment)}-fw'


var tags = {
  ProjectName: 'WVD' // defined at resource level
  EnvironmentType: environment // <Dev><Test><Uat><Prod><ProdDr>
  Location: 'AzureWestEurope' // <CSP><AzureRegion>
}

//---------------------------------------------------------------------
// -----------------  monitoringResourceGroup  ------------------------
//---------------------------------------------------------------------

resource monitoringResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitoringResourceGroupName
  location: location
}

module monitoringResources 'monitoring/monitoringResources.bicep' = {
  scope: monitoringResourceGroup
  name: 'monitoringResources_Deploy'
  dependsOn: [
    monitoringResourceGroup
  ]
  params: {
    location:location
    environment: environment
    tags: tags
    deployLogWorkspace: deployLogWorkspace
    existingLogWorkspaceName: existingLogWorkspaceName
  }
}

//---------------------------------------------------------------------
// -----------------  networkingResourceGroup  ------------------------
//---------------------------------------------------------------------

resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: networkingResourceGroupName
  location: location
}

module networkingResources 'networking/networkingResources.bicep' = {
  scope: networkingResourceGroup
  name: 'networkingResources_Deploy'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    location: location
    environment: environment
    tags: tags
    vnetsInfo: vnetsInfo
    vwanName: vwanName
    hubInfo: hubInfo
    monitoringResourceGroupName: monitoringResourceGroupName
    logWorkspaceName: monitoringResources.outputs.logWorkspaceName
    fwPolicyInfo: fwPolicyInfo
    appRuleCollectionGroupName: appRuleCollectionGroupName
    appRulesInfo: appRulesInfo
    networkRuleCollectionGroupName: networkRuleCollectionGroupName
    networkRulesInfo: networkRulesInfo
    firewallName: firewallName
    fwPublicIpName: fwPublicIpName
  }
}

output logWorkspaceName string = monitoringResources.outputs.logWorkspaceName
