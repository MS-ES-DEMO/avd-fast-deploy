@description('The base URI where artifacts required by this template are located.')
param DSCModule object = {
  url: 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip'
  configuration: 'Configuration.ps1\\AddSessionHost'
}
param vmGalleryImage object = {
  imageOffer: 'Windows-10'
  imageSKU: '20h1-pro'
  imagePublisher: 'MicrosoftWindowsDesktop'
}

@description('This prefix will be used in combination with the VM number to create the VM name. This value includes the dash, so if using “rdsh” as the prefix, VMs would be named “rdsh-0”, “rdsh-1”, etc. You should use a unique prefix to reduce name collisions in Active Directory.')
param rdshPrefix string = 'wvd-vm-'

@description('Number of session hosts that will be created and added to the hostpool.')
param rdshNumberOfInstances int

@description('The VM disk type for the VM: HDD or SSD.')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('The size of the session host VMs.')
param rdshVmSize string = 'Standard_D2s_v3'

@description('Enables Accelerated Networking feature, notice that VM size must support it, this is supported in most of general purpose and compute-optimized instances with 2 or more vCPUs, on instances that supports hyperthreading it is required minimum of 4 vCPUs.')
param enableAcceleratedNetworking bool = false

@description('The username for the admin.')
param domainAccountUsername string = ''

@description('The password that corresponds to the existing domain username.')
@secure()
param domainAccountPassword string

@description('')
param Vnet object

@description('Location for all resources to be created in.')
param location string = resourceGroup().location

@description('The tags to be assigned to the network interfaces')
param networkInterfaceTags object = {}

@description('The tags to be assigned to the virtual machines')
param virtualMachineTags object = {}

@description('VM name prefix initial number.')
param vmInitialNumber int = 1

@description('The token for adding VMs to the hostpool')
param hostpoolToken string = ''

@description('The name of the hostpool')
param hostpoolName string

@description('OUPath for the domain join')
param ouPath string = ''

@description('Domain to join')
param domain string = ''
param avsName string
param vmLocalUser object

var domain_var = ((domain == '') ? last(split(domainAccountUsername, '@')) : domain)
var subnetID = resourceId(Vnet.resourceGroup, 'Microsoft.Network/virtualNetworks/subnets', Vnet.name, Vnet.subnet)

resource rdshPrefix_vmInitialNumber_nic0 'Microsoft.Network/networkInterfaces@2018-11-01' = [for i in range(0, rdshNumberOfInstances): {
  name: '${rdshPrefix}${(i + vmInitialNumber)}-nic0'
  location: location
  tags: networkInterfaceTags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
  dependsOn: []
}]

resource rdshPrefix_vmInitialNumber 'Microsoft.Compute/virtualMachines@2018-10-01' = [for i in range(0, rdshNumberOfInstances): {
  name: concat(rdshPrefix, (i + vmInitialNumber))
  location: location
  tags: virtualMachineTags
  properties: {
    hardwareProfile: {
      vmSize: rdshVmSize
    }
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets/', avsName)
    }
    osProfile: {
      computerName: concat(rdshPrefix, (i + vmInitialNumber))
      adminUsername: vmLocalUser.administrator
      adminPassword: vmLocalUser.password
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: vmGalleryImage.imagePublisher
        offer: vmGalleryImage.imageOffer
        sku: vmGalleryImage.imageSKU
        version: 'latest'
      }
      osDisk: {
        name: '${rdshPrefix}${(i + vmInitialNumber)}-OsDisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${rdshPrefix}${(i + vmInitialNumber)}-nic0')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    licenseType: 'Windows_Client'
  }
  dependsOn: [
    'Microsoft.Network/networkInterfaces/${rdshPrefix}${(i + vmInitialNumber)}-nic0'
  ]
}]

resource rdshPrefix_vmInitialNumber_joindomain 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = [for i in range(0, rdshNumberOfInstances): {
  name: '${rdshPrefix}${(i + vmInitialNumber)}/joindomain'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domain_var
      ouPath: ouPath
      user: domainAccountUsername
      restart: 'true'
      options: '3'
    }
    protectedSettings: {
      password: domainAccountPassword
    }
  }
  dependsOn: [
    rdshPrefix_vmInitialNumber
  ]
}]

resource rdshPrefix_vmInitialNumber_dscextension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = [for i in range(0, rdshNumberOfInstances): {
  name: '${rdshPrefix}${(i + vmInitialNumber)}/dscextension'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: DSCModule.url
      configurationFunction: DSCModule.configuration
      properties: {
        hostPoolName: hostpoolName
        registrationInfoToken: reference(resourceId('Microsoft.DesktopVirtualization/hostpools', hostpoolName), '2019-12-10-preview', 'Full').properties.registrationInfo.token
      }
    }
  }
  dependsOn: [
    rdshPrefix_vmInitialNumber_joindomain
    rdshPrefix_vmInitialNumber
  ]
}]