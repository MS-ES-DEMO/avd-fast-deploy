
param location string = resourceGroup().location
param tags object
param name string 
//TODO: COMPLETE

resource extension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    enableAutomaticUpgrade: true
    autoUpgradeMinorVersion: true
    settings: {
      
    }
  }
}

