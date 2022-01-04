targetScope = 'subscription'

// Global Parameters

@description('Azure region where resource would be deployed')
param location string
<<<<<<< HEAD
@description('Tags associated with all resources')
param tags object 
=======
@description('Environment: Dev,Test,PreProd,Uat,Prod,ProdDr.')
@allowed([
  'dev'
  'test'
  'pre'
  'uat'
  'prod'
  'proddr'
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
>>>>>>> main

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

var newOrExistingWorkspaceName = avdConfiguration.workSpace.name

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

var appsListInfo = avdConfiguration.hostPool.apps

// Azure Virtual Desktop Scale Plan

var scalingPlanName = avdConfiguration.hostPool.scalePlan.name
var timeZone  = avdConfiguration.hostPool.scalePlan.timeZone
var schedules  = avdConfiguration.hostPool.scalePlan.schedules
var scalingPlanEnabled = avdConfiguration.hostPool.scalePlan.enabled
var exclusionTag = avdConfiguration.hostPool.scalePlan.exclusionTag


// Azure Virtual Desktop Monitoring Configuration

var deployWorkspaceDiagnostic = avdConfiguration.workSpace.deployDiagnostics
var deployHostPoolDiagnostic = avdConfiguration.monitoring.deployHostPoolDiagnostics
var deployDesktopApplicationGroupDiagnostic = avdConfiguration.monitoring.deployDesktopDiagnostics
var deployRemoteAppApplicationGroupDiagnostic = avdConfiguration.monitoring.deployRemoteAppDiagnostics

// FSLogix User Profiles resources

var profileStorageAccountName = avdConfiguration.profiles.storageAccountName
var profileFileShareName = avdConfiguration.profiles.fileShareName
var profilePrivateEndpointName = avdConfiguration.profiles.privateEndpointConfig.name
var profilePrivateEndpointVnetName = avdConfiguration.profiles.privateEndpointConfig.vnetName
var profilePrivateEndpointSubnetName = avdConfiguration.profiles.privateEndpointConfig.snetName
var profilePrivateEndpointDnsZoneName = avdConfiguration.profiles.privateEndpointConfig.dnsZoneName
var profilePrivateEndpointDnsZoneResourceGroupName = avdConfiguration.profiles.privateEndpointConfig.dnsZoneResourceGroupName

/* 
  AVD Resource Group deployment 
*/
resource avdResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: avdResourceGroupName
  location: location
}

/* 
  Azure RBAC role resources deployment 
*/
module iamResources 'iam/iamResources.bicep' = if (newScenario) {
  name: 'iamRss_Deploy'
  params: {
    avdAutoscaleRoleInfo: avdAutoscaleRoleInfo
    avdStartOnConnectRoleInfo: avdStartOnConnectRoleInfo
  }
}

/* 
  Azure Virtual Desktop resources deployment 
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

/*
  FSLogix User Profiles resources
*/
module userProfilesFileShare 'profilesShare/userProfileStorage.bicep' = if (avdConfiguration.hostPool.type == 'Pooled') {
  name: 'userProfilesFileShare_Deploy'
  scope: avdResourceGroup
  params: {
    name: profileStorageAccountName
    location: location
    tags: tags
    fileShareName: profileFileShareName
    vnetName: profilePrivateEndpointVnetName
    snetName: profilePrivateEndpointSubnetName
    privateEndpointName: profilePrivateEndpointName
    privateDnsZoneName: profilePrivateEndpointDnsZoneName
    privateDnsZoneResourceGroupName: profilePrivateEndpointDnsZoneResourceGroupName
  }
}

