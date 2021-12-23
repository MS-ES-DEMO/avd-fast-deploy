targetScope = 'subscription'

// Global Parameters

@description('Azure region where resource would be deployed')
param location string
@description('Tags associated with all resources')
param tags object 

// Resource Group Names

@description('Resource Groups names')
param resourceGroupNames object

var monitoringResourceGroupName = resourceGroupNames.monitoring
var networkAvdResourceGroupName = resourceGroupNames.avd
var avdResourceGroupName = resourceGroupNames.avd

// Monitoring resources

@description('Monitoring options')
param monitoringOptions object

var logWorkspaceName = monitoringOptions.newOrExistingLogAnalyticsWorkspaceName
var diagnosticsStorageAccountName = monitoringOptions.diagnosticsStorageAccountName

// Role definitions

@description('Azure ARM RBAC role definitions to configure for autoscale and start on connect')
param roleDefinitions object

var avdAutoscaleRoleInfo = roleDefinitions.avdAutoScaleRole
var avdStartOnConnectRoleInfo = roleDefinitions.avdStartOnConnectRole

// Pool VM configuration

@description('Virtual Machine configuration')
param vmConfiguration object

var vmPrefix = vmConfiguration.prefixName
var vmDiskType = vmConfiguration.diskType
var vmSize = vmConfiguration.sku
var vmGalleryImage = vmConfiguration.image
var localVmAdminUsername = vmConfiguration.adminUsername
@secure()
param localVmAdminPassword string

var domainToJoin = vmConfiguration.domainConfiguration.name
var ouPath = vmConfiguration.domainConfiguration.ouPath
var existingDomainAdminName = vmConfiguration.domainConfiguration.vmJoinUserName
@secure()
param existingDomainAdminPassword string

var artifactsLocation = vmConfiguration.domainConfiguration.artifactsLocation

var existingAvdVnetName = vmConfiguration.networkConfiguration.vnetName 
var existingSubnetName = vmConfiguration.networkConfiguration.subnetName 

// Azure Virtual Desktop Configuration

@description('Azure Virtual Desktop Configuration')
param avdConfiguration object

// Azure Virtual Desktop Workspace Configuration

param deploymentFromScratch bool
var newScenario = deploymentFromScratch

var newOrExistingLogAnalyticsWorkspaceName = monitoringOptions.newOrExistingLogAnalyticsWorkspaceName
var newOrExistingWorkspaceName = newOrExistingLogAnalyticsWorkspaceName

var tokenExpirationTime  = avdConfiguration.workSpace.tokenExpirationTime


// Azure Virtual Desktop Pool Configuration

var addHost = avdConfiguration.hostPool.addHosts

var hostPoolName = avdConfiguration.hostPool.name
var hostPoolFriendlyName = hostPoolName
var hostPoolType = avdConfiguration.hostPool.type
var personalDesktopAssignmentType = avdConfiguration.hostPool.assignmentType

var avdNumberOfInstances = avdConfiguration.hostPool.instances
var currentInstances = 0
var maxSessionLimit = avdConfiguration.hostPool.maxSessions

var customRdpProperty = avdConfiguration.hostPool.rdpProperties

var desktopApplicationGroupName = '${hostPoolName}-dag'
var remoteAppApplicationGroupName = '${hostPoolName}-rag'

param appsListInfo array = []


// Azure Virtual Desktop Scale Plan

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


// Azure Virtual Desktop Monitoring Configuration

var deployWorkspaceDiagnostic = avdConfiguration.workSpace.deployDiagnostics
var deployHostPoolDiagnostic = avdConfiguration.monitoring.deployHostPoolDiagnostics
var deployDesktopApplicationGroupDiagnostic = avdConfiguration.monitoring.deployDesktopDiagnostics
var deployRemoteAppApplicationGroupDiagnostic = avdConfiguration.monitoring.deployRemoteAppDiagnostics


/* 
  Monitoring resources deployment 
*/
resource avdResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: avdResourceGroupName
  location: location
}

/* 
  Monitoring resources deployment 
*/
module iamResources 'iam/iamResources.bicep' = if (newScenario) {
  name: 'iamRss_Deploy'
  params: {
    avdAutoscaleRoleInfo: avdAutoscaleRoleInfo
    avdStartOnConnectRoleInfo: avdStartOnConnectRoleInfo
  }
}

/* 
  Monitoring resources deployment 
*/
module environmentResources 'environment/environmentResources.bicep' = if (newScenario) {
  scope: avdResourceGroup
  name: 'environmentRssFor${hostPoolType}_${uniqueString(hostPoolName)}_Deploy'
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

/* 
  Azure Virtual Desktop Hosts resources deployment 
*/
module addHostResources 'addHost/addHostResources.bicep' = if (addHost) {
  scope: avdResourceGroup
  name: 'addHostRssFor${hostPoolType}_${uniqueString(hostPoolName)}_Deploy'
  dependsOn: [
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


