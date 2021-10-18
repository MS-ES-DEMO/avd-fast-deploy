
param location string = resourceGroup().location
param tags object
param name string 
param vmName string
param artifactsLocation string
param domainName string
param adminUsername string
@secure()
param adminPassword string

resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' existing = {
  name: vmName
}

resource extension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: name
  parent: vm
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    enableAutomaticUpgrade: true
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: uri(artifactsLocation, 'createADPDC.zip')
      ConfigurationFunction: 'createADPDC.ps1\\createADPDC'
      Properties: {
        DomainName: domainName
        AdminCreds: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:adminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        adminPassword: adminPassword
      }
    }
  }
}
