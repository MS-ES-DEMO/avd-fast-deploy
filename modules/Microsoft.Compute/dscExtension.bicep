
param location string = resourceGroup().location
param tags object
param name string 
param vmName string
param artifactsLocation string
param hostPoolName string



resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' existing = {
  name: vmName
}

resource hostpools 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' existing = {
  name: hostPoolName
}

resource dscextension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: name
  parent: vm
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: uri(artifactsLocation, 'Configuration.zip')
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        HostPoolName: hostPoolName
        registrationInfoToken: hostpools.properties.registrationInfo.token
      }
    }
  }
}

