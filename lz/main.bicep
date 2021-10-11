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
param env string
// resourceGroupNames
@description('Name for monitoring RG')
param monitoringResourceGroupName string
@description('Name for hub RG')
param hubResourceGroupName string
@description('Name for DNS RG')
param dnsResourceGroupName string
@description('Name for shared services RG')
param sharedResourceGroupName string
@description('Name for spoke1 RG')
param spoke1ResourceGroupName string
@description('Name for security RG')
param securityResourceGroupName string
@description('Name for AWVD RG')
param awvdResourceGroupName string


// monitoringResources
@description('Deploy Log Analytics Workspace?')
param deployLogWorkspace bool
@description('Name for existing Log Analytics Workspace')
param existingLogWorkspaceName string = ''


// securityResources


// dnsResources

@description('Name and range for DNS vNet')
param dnsVnetInfo object = {
    name: 'vnet-${toLower(env)}-dns'
    range: '10.0.1.0/24'
}
@description('Name and range for DNS subnets')
param dnsSnetsInfo array = [
  {
  name: 'snet-${toLower(env)}-dns'
  range: '10.0.1.0/26'
  }
]
@description('Name and rules for DNS nsg')
param dnsNicNsgInfo object = {
  name: 'nsg-${toLower(env)}-nic-dns'
  inboundRules: [
    {
      name: 'rule1'
      rule: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '10.0.1.0/24'
        destinationAddressPrefix: '10.0.1.0/26'
        access: 'Allow'
        priority: 300
        direction: 'Inbound'
      }
    }
    {
      name: 'rule2'
      rule: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '10.0.1.0/24'
        destinationAddressPrefix: '10.0.1.0/24'
        access: 'Allow'
        priority: 301
        direction: 'Inbound'
      }
    }
  ]
}
@description('Name for DNS nic')
param dnsNicName string = 'nic-${toLower(env)}-dns'
@description('Name for DNS vm')
param vmDnsName string = 'vm-${toLower(env)}-dns'
@description('Size for DNS vm')
param vmDnsSize string = 'Standard_DS3_V2'
@description('Admin username for DNS vm')
@secure()
param vmDnsAdminUsername string
@description('Admin password for DNS vm')
@secure()
param vmDnsAdminPassword string


// sharedResources

@description('Name and range for shared services vNet')
param sharedVnetInfo object = {
    name: 'vnet-${toLower(env)}-shared'
    range: '10.0.2.0/24'
}
@description('Name and range for shared subnets')
param sharedSnetsInfo array = [
  {
  name: 'snet-${toLower(env)}-jump'
  range: '10.0.2.0/26'
  }
]
@description('Nsg info for Jump Nic')
param jumpNicNsgInfo object = {
  name: 'nsg-${toLower(env)}-nic-jump'
  inboundRules: [
    {
      name: 'rule1'
      rule: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '10.0.1.0/24'
        destinationAddressPrefix: '10.0.1.0/26'
        access: 'Allow'
        priority: 300
        direction: 'Inbound'
      }
    }
    {
      name: 'rule2'
      rule: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '10.0.1.0/24'
        destinationAddressPrefix: '10.0.1.0/24'
        access: 'Allow'
        priority: 301
        direction: 'Inbound'
      }
    }
  ]
}
@description('Name for Jump Nic')
param jumpNicName string = 'nic-${toLower(env)}-jump'
@description('Deploy Custom DNS on Shared Services vnet?')
param deployCustomDnsOnSharedVnet bool = true
@description('Name for Jump vm')
param vmJumpName string = 'vm-${toLower(env)}-jump'
@description('Size for Jump vm')
param vmJumpSize string = 'Standard_DS3_V2'
@description('Admin username for Jump vm')
@secure()
param vmJumpAdminUsername string
@description('Admin password for Jump vm')
@secure()
param vmJumpAdminPassword string

// spoke1Resources

@description('Name and range for spoke1 services vNet')
param spoke1VnetInfo object = {
    name: 'vnet-${toLower(env)}-spoke1'
    range: '10.0.3.0/24'
}
@description('Name and range for spoke1 subnets')
param spoke1SnetsInfo array = [
  {
  name: 'snet-${toLower(env)}-app'
  range: '10.0.3.0/26'
  }
  {
  name: 'snet-${toLower(env)}-plinks'
  range: '10.0.3.64/26'
  }
]
@description('Nsg info for spoke1 Nic')
param spoke1NicNsgInfo object = {
  name: 'nsg-${toLower(env)}-nic-spoke1'
  inboundRules: [
    {
      name: 'rule1'
      rule: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '10.0.1.0/24'
        destinationAddressPrefix: '10.0.1.0/26'
        access: 'Allow'
        priority: 300
        direction: 'Inbound'
      }
    }
    {
      name: 'rule2'
      rule: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '10.0.1.0/24'
        destinationAddressPrefix: '10.0.1.0/24'
        access: 'Allow'
        priority: 301
        direction: 'Inbound'
      }
    }
  ]
}
@description('Name for Spoke1 Nic')
param spoke1NicName string = 'nic-${toLower(env)}-spoke1'
@description('Deploy Custom DNS on spoke1 vnet?')
param deployCustomDnsOnSpoke1Vnet bool = true
@description('Name for spoke1 vm')
param vmSpoke1Name string = 'vm-${toLower(env)}-spo1'
@description('Size for Spoke1 vm')
param vmSpoke1Size string = 'Standard_DS3_V2'
@description('Admin username for Spoke1 vm')
@secure()
param vmSpoke1AdminUsername string
@description('Admin password for Spoke1 vm')
@secure()
param vmSpoke1AdminPassword string




// hubResources


@description('Name for VWAN')
param vwanName string = 'vwan-${toLower(env)}-001'
@description('Name and range for Hub')
param hubInfo object = {
    name: 'hub-${toLower(env)}-001'
    range: '10.0.0.0/24'
}
@description('Name and snat ranges for fw policy')
param fwPolicyInfo object = {
  name: 'fwpolicy-${toLower(env)}-001'
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
param appRuleCollectionGroupName string = 'fwapprulegroup-${toLower(env)}'
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
            format('*.monitor.{0}', environment().suffixes.storage)
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
param networkRuleCollectionGroupName string = 'fwnetrulegroup-${toLower(env)}'
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

@description('Name for Azure Firewall public ip')
param fwPublicIpName string = 'pip-${toLower(env)}-fw'
@description('Name for Azure Firewall')
param firewallName string = 'azfw-${toLower(env)}'
@description('Name for hub virtual connections')
param hubVnetConnectionsInfo array = [
  {
    name: 'hub-to-dns'
    remoteVnetName: 'vnet-${toLower(env)}-dns'
    resourceGroup: dnsResourceGroupName
  }
  {
    name: 'hub-to-shared'
    remoteVnetName: 'vnet-${toLower(env)}-shared'
    resourceGroup: sharedResourceGroupName
  }
  {
    name: 'hub-to-awvd'
    remoteVnetName: 'vnet-${toLower(env)}-awvd'
    resourceGroup: awvdResourceGroupName
  }
  {
    name: 'hub-to-spoke1'
    remoteVnetName: 'vnet-${toLower(env)}-spoke1'
    resourceGroup: spoke1ResourceGroupName
  }
]
@description('Name for storage account')
param storageAccountName string = 'blob${toLower(env)}spoke1'
@description('Name for blob storage private endpoint')
param blobStorageAccountPrivateEndpointName string = 'plink-blob-${toLower(env)}-spoke1'

// awvdResources

@description('Name and range for awvd vNet')
param awvdVnetInfo object = {
    name: 'vnet-${toLower(env)}-awvd'
    range: '10.0.4.0/23'
}
@description('Name and range for Azure Files subnet')
param azureFilesAwvdSnetInfo array = [
  {
  name: 'snet-${toLower(env)}-azurefiles'
  range: '10.0.4.0/27'
  }
]
@description('Name and range for new awvd subnet')
param newAwvdSnetInfo array = [
  {
  name: 'snet-${toLower(env)}-hostpool1'
  range: '10.0.4.32/27'
  }
]
@description('Name and range for existing awvd subnets')
param existingAwvdSnetsInfo array = []


param fslogixStorageAccountName string = 'fslogix${toLower(env)}profiles'
param fslogixFileStorageAccountPrivateEndpointName string = 'plink-fslogix-${toLower(env)}-profiles'



var awvdSnetsInfo = union(azureFilesAwvdSnetInfo, newAwvdSnetInfo, existingAwvdSnetsInfo) 


var privateDnsZonesInfo = [
  {
    name: format('privatelink.blob.{0}', environment().suffixes.storage)
    vnetLinkName: 'vnet-link-blob-to-'
    vnetName: 'vnet-${toLower(env)}-dns'
  }
  {
    name: format('privatelink.file.{0}', environment().suffixes.storage)
    vnetLinkName: 'vnet-link-file-to-'
    vnetName: 'vnet-${toLower(env)}-dns'
  }
  {
    name: format('privatelink{0}', environment().suffixes.sqlServerHostname)
    vnetLinkName: 'vnet-link-sqldatabase-to-'
    vnetName: 'vnet-${toLower(env)}-dns'
  }
]

var tags = {
  ProjectName: 'WVD' // defined at resource level
  EnvironmentType: env // <Dev><Test><Uat><Prod><ProdDr>
  Location: 'AzureWestEurope' // <CSP><AzureRegion>
}

var privateTrafficPrefix = [
    '0.0.0.0/0'
    '172.16.0.0/12' 
    '192.168.0.0/16'
    '${sharedVnetInfo.range}'
    '${dnsVnetInfo.range}'
    '${spoke1VnetInfo.range}'
    '${awvdVnetInfo.range}'
]


resource monitoringResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitoringResourceGroupName
  location: location
}

resource securityResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: securityResourceGroupName
  location: location
}

resource dnsResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: dnsResourceGroupName
  location: location
}

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: sharedResourceGroupName
  location: location
}

resource spoke1ResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: spoke1ResourceGroupName
  location: location
}

resource awvdResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: awvdResourceGroupName
  location: location
}

resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: hubResourceGroupName
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
    env: env
    tags: tags
    deployLogWorkspace: deployLogWorkspace
    existingLogWorkspaceName: existingLogWorkspaceName
  }
}

module dnsResources 'dns/dnsResources.bicep' = {
  scope: dnsResourceGroup
  name: 'dnsResources_Deploy'
  dependsOn: [
    dnsResourceGroup
    monitoringResources
  ]
  params: {
    location:location
    tags: tags
    vnetInfo: dnsVnetInfo 
    nsgInfo: dnsNicNsgInfo
    snetsInfo: dnsSnetsInfo
    privateDnsZonesInfo: privateDnsZonesInfo    
    nicName: dnsNicName
    deployCustomDns: false
    dnsResourceGroupName: dnsResourceGroupName
    vmName: vmDnsName
    vmSize: vmDnsSize
    vmAdminUsername: vmDnsAdminUsername
    vmAdminPassword: vmDnsAdminPassword
  }
}

module sharedResources 'shared/sharedResources.bicep' = {
  scope: sharedResourceGroup
  name: 'sharedResources_Deploy'
  dependsOn: [
    sharedResourceGroup
    dnsResources
  ]
  params: {
    location:location
    tags: tags
    vnetInfo: sharedVnetInfo 
    nsgInfo: jumpNicNsgInfo
    snetsInfo: sharedSnetsInfo
    privateDnsZonesInfo: privateDnsZonesInfo 
    nicName: jumpNicName
    deployCustomDns: deployCustomDnsOnSharedVnet
    dnsNicName: dnsNicName
    dnsResourceGroupName: dnsResourceGroupName
    vmName: vmJumpName
    vmSize: vmJumpSize
    vmAdminUsername: vmJumpAdminUsername
    vmAdminPassword: vmJumpAdminPassword
  }
}

module spoke1Resources 'spokes/spoke1Resources.bicep' = {
  scope: spoke1ResourceGroup
  name: 'spoke1Resources_Deploy'
  dependsOn: [
    spoke1ResourceGroup
    sharedResources
    dnsResources
  ]
  params: {
    location:location
    tags: tags
    vnetInfo: spoke1VnetInfo 
    nsgInfo: spoke1NicNsgInfo
    snetsInfo: spoke1SnetsInfo
    privateDnsZonesInfo: privateDnsZonesInfo 
    nicName: spoke1NicName
    deployCustomDns: deployCustomDnsOnSpoke1Vnet
    dnsNicName: dnsNicName
    dnsResourceGroupName: dnsResourceGroupName
    vmName: vmSpoke1Name
    vmSize: vmSpoke1Size
    vmAdminUsername: vmSpoke1AdminUsername
    vmAdminPassword: vmSpoke1AdminPassword
    storageAccountName: storageAccountName
    blobStorageAccountPrivateEndpointName: blobStorageAccountPrivateEndpointName
    blobPrivateDnsZoneName: privateDnsZonesInfo[0].name
  }
}

module awvdResources 'awvd/awvdResources.bicep' = {
  scope: awvdResourceGroup
  name: 'awvdResources_Deploy'
  dependsOn: [
    awvdResourceGroup
    dnsResources
    sharedResources
    spoke1Resources
  ]
  params: {
    location:location
    tags: tags
    vnetInfo: awvdVnetInfo 
    snetsInfo: awvdSnetsInfo
    privateDnsZonesInfo: privateDnsZonesInfo 
    deployCustomDns: deployCustomDnsOnSpoke1Vnet
    dnsNicName: dnsNicName
    dnsResourceGroupName: dnsResourceGroupName
    storageAccountName: fslogixStorageAccountName
    filePrivateDnsZoneName: privateDnsZonesInfo[1].name
    fileStorageAccountPrivateEndpointName: fslogixFileStorageAccountPrivateEndpointName
  }
}

module hubResources 'hub/hubResources.bicep' = {
  scope: hubResourceGroup
  name: 'hubResources_Deploy1'
  dependsOn: [
    securityResourceGroup
    hubResourceGroup
    dnsResources
    sharedResources
    awvdResources
  ]
  params: {
    location:location
    tags: tags
    securityResourceGroupName: securityResourceGroupName
    vwanName: vwanName
    hubInfo: hubInfo
    monitoringResourceGroupName: monitoringResourceGroupName
    logWorkspaceName: monitoringResources.outputs.logWorkspaceName
    hubResourceGroupName: hubResourceGroupName
    fwPolicyInfo: fwPolicyInfo
    appRuleCollectionGroupName: appRuleCollectionGroupName
    appRulesInfo: appRulesInfo
    networkRuleCollectionGroupName: networkRuleCollectionGroupName
    networkRulesInfo: networkRulesInfo 
    fwPublicIpName: fwPublicIpName
    firewallName:firewallName
    destinationAddresses: privateTrafficPrefix
    hubVnetConnectionsInfo: hubVnetConnectionsInfo
  }
}


output logWorkspaceName string = monitoringResources.outputs.logWorkspaceName
