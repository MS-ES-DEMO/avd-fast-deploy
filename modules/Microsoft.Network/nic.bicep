
param location string = resourceGroup().location
param tags object
param name string 
param snetName string
param nsgName string


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: snetName
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' existing = {
  name: nsgName
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

