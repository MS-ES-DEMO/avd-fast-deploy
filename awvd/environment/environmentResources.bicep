

// TODO: verify the required parameters

// Global Parameters

param location string
param tags object

// resourceGroupNames
param monitoringResourceGroupName string

// awvdResources Parameters
param newOrExistingWorkspaceName string
param deployWorkspaceDiagnostic bool = true
param tokenExpirationTime string
param hostPoolType string 
param hostPoolName string 
param deployHostPoolDiagnostic bool = true
param personalDesktopAssignmentType string 
param maxSessionLimit int = 12

//param loadBalancerType string = 'BreadthFirst'


param customRdpProperty string = 'audiocapturemode:i:0;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:0;redirectcomports:i:0;redirectprinters:i:0;redirectsmartcards:i:0;screen mode id:i:2;'

//param hostPoolFriendlyName string = hostPoolName

param existingApplicationGroupIds array = []

param deployDesktopApplicationGroupDiagnostic bool = true
param deployRemoteAppApplicationGroupDiagnostic bool = true


param desktopApplicationGroupName string
param remoteAppApplicationGroupName string

// monitoringResources
param logWorkspaceName string

var desktopApplicationGroupFriendlyName = '${hostPoolName}-dag'
var remoteAppApplicationGroupFriendlyName = '${hostPoolName}-rag'

var desktopApplicationGroupId = array(resourceId('Microsoft.DesktopVirtualization/applicationgroups/', desktopApplicationGroupName))
var remoteAppAppApplicationGroupId = array(resourceId('Microsoft.DesktopVirtualization/applicationgroups/', remoteAppApplicationGroupName))
var applicationGroupIds = union(existingApplicationGroupIds,desktopApplicationGroupId,remoteAppAppApplicationGroupId)

var descriptionPersonalAppGroup = 'Desktop Application Group created through the Hostpool Wizard'
var descriptionPooledAppGroup = 'Remote App Application Group created through the Hostpool Wizard'


module hostPoolResources '../../modules/Microsoft.DesktopVirtualization/hostPool.bicep' = {
  name: 'hostPoolResources_Deploy'
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
    tokenExpirationTime: tokenExpirationTime
  }
}


module desktopApplicationGroupResources '../../modules/Microsoft.DesktopVirtualization/applicationGroup.bicep' = {
  name: 'applicationGroupResources_Deploy'
  dependsOn: [
    hostPoolResources
  ]
  params: {
    location:location
    tags: tags
    name: desktopApplicationGroupName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName    
    deployDiagnostic: deployDesktopApplicationGroupDiagnostic
    hostPoolName: hostPoolName
    applicationGroupFriendlyName: desktopApplicationGroupFriendlyName
    description: descriptionPersonalAppGroup
    applicationGroupType: 'Desktop' 
  }
}

module remoteAppApplicationGroupResources '../../modules/Microsoft.DesktopVirtualization/applicationGroup.bicep' = if (hostPoolType == 'Pooled') {
  name: 'pooledApplicationGroupResources_Deploy'
  dependsOn: [
    hostPoolResources
    desktopApplicationGroupResources
  ]
  params: {
    location:location
    tags: tags
    name: remoteAppApplicationGroupName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName    
    deployDiagnostic: deployRemoteAppApplicationGroupDiagnostic
    hostPoolName: hostPoolName
    applicationGroupFriendlyName: remoteAppApplicationGroupFriendlyName
    description: descriptionPooledAppGroup
    applicationGroupType: 'RemoteApp' 
  }
}



module workspaceResources '../../modules/Microsoft.DesktopVirtualization/workspace.bicep' = {
  name: 'workspaceResources_Deploy'
  dependsOn: [
    hostPoolResources
    remoteAppApplicationGroupResources
  ]
  params: {
    location: location
    tags: tags
    name: newOrExistingWorkspaceName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName
    deployDiagnostic: deployWorkspaceDiagnostic
    applicationGroupIds: applicationGroupIds
  }
}

