

param location string = resourceGroup().location
param tags object
param artifactsLocation string
param awvdNumberOfInstances int
param currentInstances int
param hostPoolName string
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
param existingDomainAdminName string
param existingDomainAdminPassword string
param awvdResourceGroupName string
param existingVnetName string
param existingSnetName string

@description('Subscription containing the Shared Image Gallery')
param sharedImageGallerySubscription string

@description('Resource Group containing the Shared Image Gallery.')
param sharedImageGalleryResourceGroup string

@description('Name of the existing Shared Image Gallery to be used for image.')
param sharedImageGalleryName string

@description('Name of the Shared Image Gallery Definition being used for deployment. I.e: AVDGolden')
param sharedImageGalleryDefinitionname string

@description('Version name for image to be deployed as. I.e: 1.0.0')
param sharedImageGalleryVersionName string


var avSetSku = 'Aligned'
var networkAdapterPrefix = 'nic-'

var joinDomainExtensionName = 'JsonADDomainExtension'
var dscExtensionName = 'dscExtension'

module nicResources '../../modules/Microsoft.Network/nic.bicep' = [for i in range(0, awvdNumberOfInstances): {
  name: 'nicResources_Deploy${i}'
  params: {
    location: location
    tags: tags
    name: '${networkAdapterPrefix}${vmPrefix}-${i + currentInstances}'
    vnetName: existingVnetName
    vnetResourceGroupName: awvdResourceGroupName
    snetName: existingSnetName
    nsgName: ''
  }
}]

module availabilitySetResources '../../modules/Microsoft.Compute/availabilitySet.bicep' = {
  name: 'availabilitySetResources_Deploy'
  params: {
    location: location
    tags: tags
    name: '${vmPrefix}-av'
    avSetSku: avSetSku
  }
}

module vmResources '../../modules/Microsoft.Compute/vm.bicep' = [for i in range(0, awvdNumberOfInstances): {
  name: 'vmResources_Deploy'
  dependsOn: [
    nicResources
    availabilitySetResources
  ]
  params: {
    location: location
    tags: tags
    name: '${vmPrefix}-${i + currentInstances}'
    vmSize: vmSize
    availabilitySetName: '${vmPrefix}-av'
    adminUsername: localVmAdminUsername
    adminPassword: localVmAdminPassword
    nicName: '${networkAdapterPrefix}${vmPrefix}-${i + currentInstances}'
    osDiskName: '${vmPrefix}-${i + currentInstances}-os'
    storageAccountType: vmDiskType
    imageReference: '/subscriptions/${sharedImageGallerySubscription}/resourceGroups/${sharedImageGalleryResourceGroup}/providers/Microsoft.Compute/galleries/${sharedImageGalleryName}/images/${sharedImageGalleryDefinitionname}/versions/${sharedImageGalleryVersionName}'
  }
}]

module joinDomainExtensionResources '../../modules/Microsoft.Compute/joinDomainExtension.bicep' = [for i in range(0, awvdNumberOfInstances): {
  name: 'joinDomainExtensionResources_Deploy${i}'
  dependsOn: [
    vmResources
  ]
  params: {
    location: location
    tags: tags
    name: joinDomainExtensionName
    vmName: '${vmPrefix}-${i + currentInstances}'
    domainToJoin: domainToJoin
    ouPath: ouPath
    domainAdminUsername: existingDomainAdminName
    domainAdminPassword: existingDomainAdminPassword
  }
}]


module dscExtensionResources '../../modules/Microsoft.Compute/dscExtension.bicep' = [for i in range(0, awvdNumberOfInstances): {
  name: 'dscExtensionResources_Deploy${i}'
  dependsOn: [
    vmResources
    joinDomainExtensionResources
  ]
  params: {
    location: location
    tags: tags
    name: dscExtensionName
    vmName: '${vmPrefix}-${i + currentInstances}' 
    artifactsLocation: artifactsLocation
    hostPoolName: hostPoolName
  }
}]


