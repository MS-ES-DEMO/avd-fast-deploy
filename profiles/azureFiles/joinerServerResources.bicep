
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param tags object
param vnetInfo object 

param snetName string
param nicName string
param vmName string
param vmDiskType string
param vmSize string
param vmRedundancy string
param vmAzNumber int
param vmGalleryImage object

@secure()
param vmAdminUsername string
@secure()
param vmAdminPassword string
param diagnosticsStorageAccountName string
param logWorkspaceName string
param monitoringResourceGroupName string


module nicResources '../../modules/Microsoft.Network/nic.bicep' = {
  name: 'nicResources_Deploy'
  params: {
    tags: tags
    name: nicName
    location: location
    vnetName: vnetInfo.name
    vnetResourceGroupName: resourceGroup().name
    snetName: snetName
    nsgName: ''
  }
}

module vmResources '../../modules/Microsoft.Compute/vm.bicep' = {
  name: 'vmResources_Deploy'
  dependsOn: [
    nicResources
  ]
  params: {
    tags: tags
    name: vmName
    location: location
    vmSize: vmSize
    vmRedundancy: vmRedundancy
    availabilitySetName: (vmRedundancy == 'availabilitySet') ? '${vmName}-av' : ''
    availabilityZone: vmAzNumber
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    nicName: nicName
    osDiskName: '${vmName}-os'
    storageAccountType: vmDiskType
    vmGalleryImage: vmGalleryImage
  }
}

module daExtensionResources '../../modules/Microsoft.Compute/daExtension.bicep' = {
  name: 'daExtensionResources_Deploy'
  dependsOn: [
    vmResources
  ]
  params: {
    location: location
    tags: tags
    vmName: vmName
  }
}

module diagnosticsExtensionResources '../../modules/Microsoft.Compute/diagnosticsExtension.bicep' = {
  name: 'diagnosticsExtensionResources_Deploy'
  dependsOn: [
    vmResources
  ]
  params: {
    location: location
    tags: tags
    vmName: vmName
    diagnosticsStorageAccountName: diagnosticsStorageAccountName
    monitoringResourceGroupName: monitoringResourceGroupName
  }
}

module monitoringAgentExtensionResources '../../modules/Microsoft.Compute/monitoringAgentExtension.bicep' = {
  name: 'monitoringAgentExtensionResources_Deploy'
  dependsOn: [
    vmResources
  ]
  params: {
    location: location
    tags: tags
    vmName: vmName
    logWorkspaceName: logWorkspaceName
    monitoringResourceGroupName: monitoringResourceGroupName
  }
}



