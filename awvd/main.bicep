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
@description('Name for AWVD Scenario RG')
param awvdResourceGroupName string

// awvdResources Parameters
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

@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string = 'Pooled'
param hostPoolName string = 'hp-${toLower(env)}-data-pers' 
param deployHostPoolDiagnostic bool = true

@allowed([
  'Automatic'
  'Direct'
])
param personalDesktopAssignmentType string = 'Direct'
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


param deployDesktopApplicationGroupDiagnostic bool = true
param deployRemoteAppApplicationGroupDiagnostic bool = true

param existingAwvdVnetName string = 'vnet-${toLower(env)}-awvd'
param existingSubnetName string = 'snet-${toLower(env)}-hp-data-pers-001'


// monitoringResources
param logWorkspaceName string



param artifactsLocation string
param awvdNumberOfInstances int
param currentInstances int
param domainToJoin string

@description('OU Path were new AVD Session Hosts will be placed in Active Directory')
param ouPath string

param vmPrefix string
@secure()
param localVmAdminUsername string
@secure()
param localVmAdminPassword string

@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param vmDiskType string
param vmSize string
@secure()
param existingDomainAdminName string
@secure()
param existingDomainAdminPassword string

@description('Image Gallery Information')
param vmGalleryImage object = {
  imageOffer: 'Windows-10'
  imageSKU: '20h1-pro'
  imagePublisher: 'MicrosoftWindowsDesktop'
}



var desktopApplicationGroupName = '${hostPoolName}-dag'
var remoteAppApplicationGroupName = '${hostPoolName}-rag'


var tags = {
  ProjectName: 'WVD' // defined at resource level
  EnvironmentType: env // <Dev><Test><Uat><Prod><ProdDr>
  Location: 'AzureWestEurope' // <CSP><AzureRegion>
}

resource awvdResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: awvdResourceGroupName
  location: location
}

module environmentResources 'environment/environmentResources.bicep' = if (newScenario) {
  scope: awvdResourceGroup
  name: 'environmentResources_Deploy'
  dependsOn: [
    awvdResourceGroup
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
    personalDesktopAssignmentType: personalDesktopAssignmentType
    customRdpProperty: customRdpProperty
    desktopApplicationGroupName: desktopApplicationGroupName
    deployDesktopApplicationGroupDiagnostic: deployDesktopApplicationGroupDiagnostic  
    remoteAppApplicationGroupName: remoteAppApplicationGroupName
    deployRemoteAppApplicationGroupDiagnostic: deployRemoteAppApplicationGroupDiagnostic
  }
}


module addHostResources 'addHost/addHostResources.bicep' = if (addHost) {
  scope: awvdResourceGroup
  name: 'addHostResources_Deploy'
  dependsOn: [
    awvdResourceGroup
    environmentResources
  ]
  params: {
    location: location
    tags: tags
    artifactsLocation: artifactsLocation
    awvdNumberOfInstances: awvdNumberOfInstances
    currentInstances: currentInstances
    hostPoolName: hostPoolName
    domainToJoin: domainToJoin
    ouPath: ouPath
    vmPrefix: vmPrefix
    localVmAdminUsername: localVmAdminUsername
    localVmAdminPassword: localVmAdminPassword
    vmDiskType: vmDiskType
    vmSize: vmSize
    existingDomainAdminName: existingDomainAdminName
    existingDomainAdminPassword: existingDomainAdminPassword
    awvdResourceGroupName: awvdResourceGroupName
    existingVnetName: existingAwvdVnetName
    existingSnetName: existingSubnetName
    vmGalleryImage: vmGalleryImage
  }
}








