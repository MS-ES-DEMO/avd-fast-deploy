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
  'Pre'
  'Uat'
  'Prod'
  'ProdDr'
])
param env string

// resourceGroupNames
@description('Name for monitoring RG')
param monitoringResourceGroupName string
@description('Name for AVD RG containing networking resources')
param networkAvdResourceGroupName string
@description('Name for AVD Scenario RG')
param avdResourceGroupName string

// sharedResources Parameters
@description('Info for the AVD autoscale role')
param avdAutoscaleRoleInfo object
@description('Info for the AVD Start VM on connect role')
param avdStartOnConnectRoleInfo object = {
  name: 'AVD Start VM on connect (Custom)'
  description: 'Start VM on connect with AVD (Custom)'
  actions: [ 
    'Microsoft.Compute/virtualMachines/start/action'
    'Microsoft.Compute/virtualMachines/*/read'
  ]
  principalId: '26da2792-4d23-4313-b9e7-60bd7c1bf0b1'
}


// avdResources Parameters
@description('If true Host Pool, App Group and Workspace will be created. Default is to join Session Hosts to existing AVD environment')
param newScenario bool = true
@description('Add new session hosts?')
param addHost bool = false
@description('Name for the new or existing workspace')
param newOrExistingWorkspaceName string
@description('Deploy workspace diagnostic?')
param deployWorkspaceDiagnostic bool = true

@description('Expiration time for the HostPool registration token. This must be up to 30 days from todays date.')
param tokenExpirationTime string = '7/31/2022 8:55:50 AM'

param hostPoolName string
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string = 'Pooled'
param deployHostPoolDiagnostic bool = true

@allowed([
  'Automatic'
  'Direct'
])
param personalDesktopAssignmentType string = 'Automatic'
param maxSessionLimit int = 12

/*
@allowed([
  'BreadthFirst'
  'DepthFirst'
  'Persistent'
])
param loadBalancerType string = 'BreadthFirst'
*/
@description('Custom RDP properties to be applied to the AVD Host Pool.')
param customRdpProperty string = 'audiocapturemode:i:0;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:0;redirectcomports:i:0;redirectprinters:i:0;redirectsmartcards:i:0;screen mode id:i:2;'

@description('Friendly Name of the Host Pool, this is visible via the AVD client')
param hostPoolFriendlyName string = hostPoolName

@description('The name of the Scaling plan to be created.')
param scalingPlanName string = 'sp-hp-data-pool'

@description('Scaling plan autoscaling triggers and Start/Stop actions will execute in the time zone selected.')
param timeZone string = 'Romance Standard Time'

@description('The schedules of the Scaling plan to be created.')
param schedules array = []

@description('Is the scaling plan enabled for this hostpool?.')
param scalingPlanEnabled bool= false

@description('The name of the tag associated with the VMs that will be excluded from the Scaling plan.')
param exclusionTag string = ''


param deployDesktopApplicationGroupDiagnostic bool = true
param deployRemoteAppApplicationGroupDiagnostic bool = true

param existingAvdVnetName string
param existingSubnetName string


param appsListInfo array = []


// monitoringResources
param logWorkspaceName string
@description('Name for diagnostic storage account')
param diagnosticsStorageAccountName string



param artifactsLocation string = 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/"'
param avdNumberOfInstances int
param currentInstances int
param domainToJoin string

@description('OU Path were new AVD Session Hosts will be placed in Active Directory')
param ouPath string

param vmPrefix string
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param vmDiskType string
param vmSize string
@description('Image Gallery Information')
param vmGalleryImage object
param localVmAdminUsername string
@secure()
param localVmAdminPassword string
param existingDomainAdminName string
@secure()
param existingDomainAdminPassword string



var desktopApplicationGroupName = '${hostPoolName}-dag'
var remoteAppApplicationGroupName = '${hostPoolName}-rag'


var tags = {
  ProjectName: 'WVD' // defined at resource level
  EnvironmentType: env // <Dev><Test><Uat><Prod><ProdDr>
  Location: 'AzureWestEurope' // <CSP><AzureRegion>
}

resource avdResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: avdResourceGroupName
  location: location
}


module iamResources 'iam/iamResources.bicep' = if (newScenario) {
  name: 'iamRss_Deploy'
  params: {
    avdAutoscaleRoleInfo: avdAutoscaleRoleInfo
    avdStartOnConnectRoleInfo: avdStartOnConnectRoleInfo
  }
}


module environmentResources 'environment/environmentResources.bicep' = if (newScenario) {
  scope: avdResourceGroup
  name: 'environmentRssFor${hostPoolType}_${uniqueString(hostPoolName)}_Deploy'
  dependsOn: [
    avdResourceGroup
  ]
  params: {
    location: location
    tags: tags
    newOrExistingWorkspaceName: newOrExistingWorkspaceName
    deployWorkspaceDiagnostic: deployWorkspaceDiagnostic
    hostPoolName: hostPoolName
    hostPoolFriendlyName: hostPoolFriendlyName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName
    hostPoolType: hostPoolType
    deployHostPoolDiagnostic: deployHostPoolDiagnostic
    maxSessionLimit: maxSessionLimit
    tokenExpirationTime: tokenExpirationTime
    scalingPlanName: scalingPlanName
    timeZone: timeZone
    schedules: schedules
    scalingPlanEnabled: scalingPlanEnabled
    exclusionTag: exclusionTag
    personalDesktopAssignmentType: personalDesktopAssignmentType
    customRdpProperty: customRdpProperty
    desktopApplicationGroupName: desktopApplicationGroupName
    deployDesktopApplicationGroupDiagnostic: deployDesktopApplicationGroupDiagnostic  
    remoteAppApplicationGroupName: remoteAppApplicationGroupName
    deployRemoteAppApplicationGroupDiagnostic: deployRemoteAppApplicationGroupDiagnostic
    appsListInfo: appsListInfo
  }
}


module addHostResources 'addHost/addHostResources.bicep' = if (addHost) {
  scope: avdResourceGroup
  name: 'addHostRssFor${hostPoolType}_${uniqueString(hostPoolName)}_Deploy'
  dependsOn: [
    avdResourceGroup
    environmentResources
  ]
  params: {
    location: location
    tags: tags
    artifactsLocation: artifactsLocation
    avdNumberOfInstances: avdNumberOfInstances
    currentInstances: currentInstances
    hostPoolName: hostPoolName
    hostPoolType: hostPoolType
    domainToJoin: domainToJoin
    ouPath: ouPath
    vmPrefix: vmPrefix
    localVmAdminUsername: localVmAdminUsername
    localVmAdminPassword: localVmAdminPassword
    vmDiskType: vmDiskType
    vmSize: vmSize
    existingDomainAdminName: existingDomainAdminName
    existingDomainAdminPassword: existingDomainAdminPassword
    networkAvdResourceGroupName: networkAvdResourceGroupName
    existingVnetName: existingAvdVnetName
    existingSnetName: existingSubnetName
    vmGalleryImage: vmGalleryImage
    diagnosticsStorageAccountName: diagnosticsStorageAccountName
    monitoringResourceGroupName: monitoringResourceGroupName
    logWorkspaceName: logWorkspaceName
  }
}

output localVmAdminPassword string = localVmAdminPassword
output existingDomainAdminPassword string = existingDomainAdminPassword







