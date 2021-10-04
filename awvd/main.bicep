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


// monitoringResources
@description('Name for existing Log Analytics Workspace')
param existingLogWorkspaceName string = ''


var tags = {
  ProjectName: 'WVD' // defined at resource level
  EnvironmentType: env // <Dev><Test><Uat><Prod><ProdDr>
  Location: 'AzureWestEurope' // <CSP><AzureRegion>
}


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

module applicationGroupResources 'dns/dnsResources.bicep' = {
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


module hostPoolResources



module workspaceResources


