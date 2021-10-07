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
@description('Name for AWVD RG')
param awvdResourceGroupName string

// awvdResources Parameters
@description('If true Host Pool, App Group and Workspace will be created. Default is to join Session Hosts to existing AVD environment')
param newScenario bool = false
@description('Deploy a new workspace?')
param deployWorkspace bool = true
@description('Name for the existing workspace')
param existingWorkspaceName string
@description('Deploy workspace diagnostic?')
param deployWorkspaceDiagnostic bool = true

@description('Expiration time for the HostPool registration token. This must be up to 30 days from todays date.')
param tokenExpirationTime string

@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string = 'Pooled'
param hostPoolName string = 'hp-${toLower(env)}-data-pers-001' 
param deployHostPoolDiagnostic bool = true

@allowed([
  'Automatic'
  'Direct'
])
param personalDesktopAssignmentType string = 'Direct'
param maxSessionLimit int = 12

@allowed([
  'BreadthFirst'
  'DepthFirst'
  'Persistent'
])
param loadBalancerType string = 'BreadthFirst'

@description('Custom RDP properties to be applied to the AVD Host Pool.')
param customRdpProperty string = 'audiocapturemode:i:0;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:0;redirectcomports:i:0;redirectprinters:i:0;redirectsmartcards:i:0;screen mode id:i:2;'

@description('Friendly Name of the Host Pool, this is visible via the AVD client')
param hostPoolFriendlyName string = hostPoolName

param desktopApplicationGroupFriendlyName string = '${hostPoolName}-dag'
param remoteAppApplicationGroupFriendlyName string = '${hostPoolName}-rag'


@description('List of application group resource IDs to be added to Workspace. MUST add existing ones!')
param existingApplicationGroupIds array = []

param deployApplicationGroupDiagnostic bool = true

param existingAwvdVnetName string = 'vnet-${toLower(env)}-awvd'
param existingSubnetName string = 'snet-${toLower(env)}-hp-data-pers-001'


// monitoringResources
param logWorkspaceName string



var desktopApplicationGroupName = '${hostPoolName}-dag'
var remoteAppApplicationGroupName = '${hostPoolName}-rag'
var applicationGroupId = array(resourceId('Microsoft.DesktopVirtualization/applicationgroups/', applicationGroupName))
var applicationGroupIds = union(existingApplicationGroupIds,applicationGroupId)

var descriptionPersonalAppGroup = 'Desktop Application Group created through the Hostpool Wizard'
var descriptionPooledAppGroup = 'Remote App Application Group created through the Hostpool Wizard'

var tags = {
  ProjectName: 'WVD' // defined at resource level
  EnvironmentType: env // <Dev><Test><Uat><Prod><ProdDr>
  Location: 'AzureWestEurope' // <CSP><AzureRegion>
}

resource awvdResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: awvdResourceGroupName
  location: location
}

module hostPoolResources '../modules/Microsoft.DesktopVirtualization/hostPool.bicep' = {
  scope: awvdResourceGroup
  name: 'hostPoolResources_Deploy'
  dependsOn: [
    awvdResourceGroup
  ]
  params: {
    location: location
    tags: tags
    name: hostPoolName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName
    hostPoolType: hostPoolType
    deployDiagnostic: deployHostPoolDiagnostic
    maxSessionLimit: maxSessionLimit
    validationEnvironment: true
    personalDesktopAssignmentType: personalDesktopAssignmentType
    customRdpProperty: customRdpProperty
  }
}


module desktopApplicationGroupResources '../modules/Microsoft.DesktopVirtualization/applicationGroup.bicep' = {
  scope: awvdResourceGroup
  name: 'applicationGroupResources_Deploy'
  dependsOn: [
    awvdResourceGroup
    hostPoolResources
  ]
  params: {
    location:location
    tags: tags
    name: desktopApplicationGroupName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName    
    deployDiagnostic: deployApplicationGroupDiagnostic
    hostPoolName: hostPoolName
    applicationGroupFriendlyName: desktopApplicationGroupFriendlyName
    description: descriptionPersonalAppGroup
    applicationGroupType: 'Desktop' 
  }
}

module remoteAppApplicationGroupResources '../modules/Microsoft.DesktopVirtualization/applicationGroup.bicep' = if (hostPoolType == 'Pooled') {
  scope: awvdResourceGroup
  name: 'pooledApplicationGroupResources_Deploy'
  dependsOn: [
    awvdResourceGroup
    hostPoolResources
    desktopApplicationGroupResources
  ]
  params: {
    location:location
    tags: tags
    name: remoteAppApplicationGroupName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName    
    deployDiagnostic: deployApplicationGroupDiagnostic
    hostPoolName: hostPoolName
    applicationGroupFriendlyName: remoteAppApplicationGroupFriendlyName
    description: descriptionPooledAppGroup
    applicationGroupType: 'Desktop' 
  }
}



module workspaceResources '../modules/Microsoft.DesktopVirtualization/workspace.bicep' = {
  scope: awvdResourceGroup
  name: 'workspaceResources_Deploy'
  dependsOn: [
    awvdResourceGroup
    hostPoolResources
    pooledApplicationGroupResources
  ]
  params: {
    logWorkspaceName: logWorkspaceName
    awvdResourceGroupName: awvdResourceGroupName
    workspaceName: workspaceName
    deployWorkspaceDiagnostic: deployWorkspaceDiagnostic 
    applicationGroupName: applicationGroupName
    deployApplicationGrorupDiagnostic: deployApplicationGrorupDiagnostic 
    hostpoolName: hostpoolName
    deployHostpoolDiagnostic: deployHostpoolDiagnostic 
  }
}


