
param location string = resourceGroup().location
param tags object
param name string 
param vmSize string
param availabilitySetName string
@secure()
param adminUsername string 
@secure()
param adminPassword string 
param nicName string 
param osDiskName string 
param storageAccountType string 
param imageReference string

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' existing = {
  name: nicName
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2021-04-01' existing = {
  name: availabilitySetName
}

resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    licenseType: 'Windows_Client'
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: {
      id: availabilitySet.id
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    storageProfile: {
      osDisk: {
        name: osDiskName
        managedDisk: {
          storageAccountType: storageAccountType
        }
        osType: 'Windows'
        createOption: 'FromImage'
      }
      imageReference: {
        //id: resourceId(sharedImageGalleryResourceGroup, 'Microsoft.Compute/galleries/images/versions', sharedImageGalleryName, sharedImageGalleryDefinitionname, sharedImageGalleryVersionName)
        id: imageReference
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

