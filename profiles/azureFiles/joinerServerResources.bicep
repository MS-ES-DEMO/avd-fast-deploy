
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param tags object
param resourceGroupNames object
param joinerServerConfiguration object
@secure()
param vmAdminPassword string
param JsonADDomainExtensionName string
@secure()
param existingDomainAdminPassword string
param monitoringOptions object


module nicResources '../../modules/Microsoft.Network/nic.bicep' = {
  name: 'nicResources_Deploy'
  params: {
    tags: tags
    name: joinerServerConfiguration.nicName
    location: location
    vnetName: joinerServerConfiguration.networkConfiguration.vnetName
    vnetResourceGroupName: resourceGroupNames.avd
    snetName: joinerServerConfiguration.networkConfiguration.snetName
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
    name: joinerServerConfiguration.vmName
    location: location
    vmSize: joinerServerConfiguration.sku
    vmRedundancy: joinerServerConfiguration.vmRedundancy
    availabilitySetName: (joinerServerConfiguration.vmRedundancy == 'availabilitySet') ? '${joinerServerConfiguration.vmName}-av' : ''
    availabilityZone: joinerServerConfiguration.vmAzNumber
    adminUsername: joinerServerConfiguration.vmAdminUsername
    adminPassword: vmAdminPassword
    nicName: joinerServerConfiguration.networkConfiguration.nicName
    osDiskName: '${joinerServerConfiguration.vmName}-os'
    storageAccountType: joinerServerConfiguration.vmDiskType
    vmGalleryImage: joinerServerConfiguration.image
  }
}

module joinDomainExtensionResources '../../modules/Microsoft.Compute/joinDomainExtension.bicep' = {
  name: 'joinDomainExtensionRss'
  dependsOn: [
    vmResources
  ]
  params: {
    location: location
    tags: tags
    name: JsonADDomainExtensionName
    vmName: joinerServerConfiguration.vmName
    domainToJoin: joinerServerConfiguration.domainConfiguration.domainToJoin
    ouPath: joinerServerConfiguration.domainConfiguration.ouPath
    domainAdminUsername: joinerServerConfiguration.domainConfiguration.vmJoinUserName
    domainAdminPassword: existingDomainAdminPassword
  }
}

module daExtensionResources '../../modules/Microsoft.Compute/daExtension.bicep' = {
  name: 'daExtensionResources_Deploy'
  dependsOn: [
    joinDomainExtensionResources
  ]
  params: {
    location: location
    tags: tags
    vmName: joinerServerConfiguration.vmName
  }
}

module diagnosticsExtensionResources '../../modules/Microsoft.Compute/diagnosticsExtension.bicep' = {
  name: 'diagnosticsExtensionResources_Deploy'
  dependsOn: [
    daExtensionResources
  ]
  params: {
    location: location
    tags: tags
    vmName: joinerServerConfiguration.vmName
    diagnosticsStorageAccountName: monitoringOptions.diagnosticsStorageAccountName
    monitoringResourceGroupName: resourceGroupNames.monitoring
  }
}

module monitoringAgentExtensionResources '../../modules/Microsoft.Compute/monitoringAgentExtension.bicep' = {
  name: 'monitoringAgentExtensionResources_Deploy'
  dependsOn: [
    diagnosticsExtensionResources
  ]
  params: {
    location: location
    tags: tags
    vmName: joinerServerConfiguration.vmName
    logWorkspaceName: monitoringOptions.logWorkspaceName
    monitoringResourceGroupName: resourceGroupNames.monitoring
  }
}



