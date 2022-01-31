
param location string = resourceGroup().location
param tags object
param name string
param imageBuilderIdentityName string
param properties object

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: imageBuilderIdentityName
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: properties
}
