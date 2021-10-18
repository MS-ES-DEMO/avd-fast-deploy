param location string = resourceGroup().location
param tags object



param artifactsLocation string

@secure()
param AzTenantID string
param awvdNumberOfInstances int
param currentInstances int

@description('Location for all standard resources to be deployed into.')
param location string
param hostPoolName string
param domainToJoin string
@description('Name of resource group containing AVD HostPool')
param resourceGroupName string

@description('OU Path were new AVD Session Hosts will be placed in Active Directory')
param ouPath string
param appGroupName string
param desktopName string

@description('Application ID for Service Principal. Used for DSC scripts.')
param appID string

@description('Application Secret for Service Principal.')
param appSecret string

@description('CSV list of default users to assign to AVD Application Group.')
param defaultUsers string
param vmPrefix string

@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param vmDiskType string
param vmSize string
param administratorAccountUserName string
param administratorAccountPassword string
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
var existingDomainUserName = first(split(administratorAccountUserName, '@'))
var numberOfInstances = (currentInstances + AVDnumberOfInstances)
var copyIndexOffset = ((currentInstances > 0) ? currentInstances : 0)
var networkAdapterPrefix = 'nic-'

var joinDomainExtensionName = 'JsonADDomainExtension'
var dscExtensionName = 'dscExtension'

module nicResources '../../modules/Microsoft.Network/nic.bicep' = [for i in range(0, awvdNumberOfInstances): {
  name: 'nicResources_Deploy${i}'
  params: {
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
    tags: tags
    name: '${vmPrefix}-av'
    avSetSku: avSetSku
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
    vmSize: vmSize
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    nicName: nicName
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0, AVDnumberOfInstances): {
  name: '${vmPrefix}-${i + currentInstances}'
  location: location
  properties: {
    licenseType: 'Windows_Client'
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets', '${vmPrefix}-AV')
    }
    osProfile: {
      computerName: '${vmPrefix}-${i + currentInstances}'
      adminUsername: existingDomainUserName
      adminPassword: administratorAccountPassword
      windowsConfiguration: {
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
    }
    storageProfile: {
      osDisk: {
        name: '${vmPrefix}-${i + currentInstances}-OS'
        managedDisk: {
          storageAccountType: vmDiskType
        }
        osType: 'Windows'
        createOption: 'FromImage'
      }
      imageReference: {
        //id: resourceId(sharedImageGalleryResourceGroup, 'Microsoft.Compute/galleries/images/versions', sharedImageGalleryName, sharedImageGalleryDefinitionname, sharedImageGalleryVersionName)
        id: '/subscriptions/${sharedImageGallerySubscription}/resourceGroups/${sharedImageGalleryResourceGroup}/providers/Microsoft.Compute/galleries/${sharedImageGalleryName}/images/${sharedImageGalleryDefinitionname}/versions/${sharedImageGalleryVersionName}'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmPrefix}-${i + currentInstances}${networkAdapterPostfix}')
        }
      ]
    }
  }
  dependsOn: [
    availabilitySet
    nic[i]
  ]
}]


module joinDomainExtensionResources '../../modules/Microsoft.Compute/joinDomainExtension.bicep' = [for i in range(0, awvdNumberOfInstances): {
  name: 'joinDomainExtensionResources_Deploy${i}'
  params: {
    tags: tags
    name: joinDomainExtensionName
    vmName: '${vmPrefix}-${i + currentInstances}'
    domainToJoin: domainToJoin
    ouPath: ouPath
    administratorAccountUserName: administratorAccountUserName
    administratorAccountPassword: administratorAccountPassword
  }
}]


module dscExtensionResources '../../modules/Microsoft.Compute/dscExtension.bicep' = [for i in range(0, awvdNumberOfInstances): {
  name: 'dscExtensionResources_Deploy${i}'
  params: {
    tags: tags
    name: dscExtensionName
    vmName: '${vmPrefix}-${i + currentInstances}' 
    artifactsLocation: artifactsLocation
    hostPoolName: hostPoolName
  }
}]


