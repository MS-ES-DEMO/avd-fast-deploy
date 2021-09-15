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
param existingWorkspaceName string = ''

// networkingResources
@description('Name for Networking RG')
param networkingResourceGroupName string
@description('Name and range for vNets')
param vNetsInfo array = [
  {
    name: 'vnet-hub'
    range: '10.0.0.0/24'
  }
  {
    name: 'vnet-addsanddns'
    range: '10.0.1.0/24'
  }
  {
    name: 'vnet-wvd'
    range: '10.0.2.0/24'
  }
]

var tags = {
  ProjectName: 'WVD' // defined at resource level
  EnvironmentType: environment // <Dev><Test><Uat><Prod><ProdDr>
  Location: 'AzureWestEurope' // <CSP><AzureRegion>
}

// -----------------  monitoringResourceGroup  ------------------------
resource monitoringResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitoringResourceGroupName
  location: location
}

module monitoringResources 'modules/monitoringResources.bicep' = {
  scope: resourceGroup(monitoringResourceGroupName)
  name: 'MonitoringResources_Deploy'
  dependsOn: [
    monitoringResourceGroup
  ]
  params: {
    deployLogWorkspace: deployLogWorkspace
    environment: environment
    tags: tags
    existingLogWorkspaceName: existingWorkspaceName
  }
  
}

// -----------------  networkingResourceGroup  ------------------------

resource networkingResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: networkingResourceGroupName
  location: location
}

module vnets 'modules/vnets.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnets_Deploy'
  dependsOn: [
    networkingResourceGroup
  ]
  params: {
    location: location
    environment: environment
    vNetsInfo: vNetsInfo
    tags: tags
  }
  
}


/*
module firewall 'modules/azureFirewall.bicep' = {
  scope: resourceGroup(vnetResourceGroup)
  name: 'AzureFirewall_Deploy'
  params: {
    environment: environment
    firewallVnetName: vnetName
    logAnalyticsResourceGroupName: diagnosticsResourceGroup
    logAnalyticsWorkspaceName: deployLogWorkspace ? monitoringResources.outputs.newWorkspaceName : existingWorkspaceName
    vnetResourceGroup: vnetResourceGroup
    appsRouteTableName: appsRouteTableName
    appsSubnetName: appServerSubnetName
    clientsRouteTableName: clientsRouteTableName
    clientsSubnetName: clientsSubnetName
    dbRouteTableName: dbRouteTableName
    dbSubnetName: sqlMiSubnetName
    gatewayRouteTableName: gatewayRouteTableName
    onPremisesIpAddressPrefix: onPremisesIpAddressPrefix
  }
  
}

*/

output newWorkspaceName string = monitoringResources.outputs.newWorkspaceName
