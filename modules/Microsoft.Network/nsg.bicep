
param location string = resourceGroup().location
param tags object
param environment string
param snetInfo object


resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: snetInfo.nsgName
  location: location
  tags: tags
}
