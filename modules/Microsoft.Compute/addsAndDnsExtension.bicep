param vmName string
param artifactsLocation string

@secure()
param artifactsLocationSasToken string
param domainName string

@secure()
param AdminPassword string
param adminUsername string

resource vmName_CreateADForest 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: '${vmName}/CreateADForest'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: uri(artifactsLocation, 'DSC/NewAD/CreateADPDC.zip${artifactsLocationSasToken}')
      ConfigurationFunction: 'CreateADPDC.ps1\\CreateADPDC'
      Properties: {
        DomainName: domainName
        AdminCreds: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:AdminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        AdminPassword: AdminPassword
      }
    }
  }
}