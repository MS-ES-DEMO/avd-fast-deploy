
param location string = resourceGroup().location
param tags object
param environment string
param snetInfo object


resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: snetInfo.nsgName
  location: location
  tags: tags
}
