
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param env string
param tags object
param networkingResourceGroupName string
param deployPublicIpJump bool
param nicJumpName string
param subnetJumpName string
param nsgJumpNicName string
param vmJumpName string
param vmJumpSize string
@secure()
param vmJumpAdminUsername string
@secure()
param vmJumpAdminPassword string
param deployPublicIpDns bool
param nicDnsName string
param subnetDnsName string
param nsgDnsNicName string
param vmDnsName string
param vmDnsSize string
@secure()
param vmDnsAdminUsername string
@secure()
param vmDnsAdminPassword string



var publicIpJumpName = 'pip-${toLower(env)}-jump'
var publicIpDnsName = 'pip-${toLower(env)}-dns'



module publicIpJumpResources '../modules/Microsoft.Network/publicIp.bicep' = if (deployPublicIpJump) {
  name: 'publicIpJumpResources_Deploy'
  params: {
    location: location
    tags: tags
    name: publicIpJumpName
  }
}

module nsgJumpNicResources '../modules/Microsoft.Network/nsg.bicep' = {
  name: 'nsgJumpNicResources_Deploy'
  params: {
    location: location
    tags: tags
    name: nsgJumpNicName
    snetInfo: {}
  }
}

module nicJumpResources '../modules/Microsoft.Network/nic.bicep' = {
  name: 'nicJumpResources_Deploy'
  params: {
    location: location
    tags: tags
    name: nicJumpName 
    snetName: subnetJumpName
    networkingResourceGroupName: networkingResourceGroupName
    deployPublicIp: deployPublicIpJump
    publicIpName: publicIpJumpName
    nsgName: nsgJumpNicName 
  }
}


module vmJumpResources '../modules/Microsoft.Compute/vm.bicep' = {
  name: 'jumpVmcResources_Deploy'
  params: {
    location: location
    tags: tags
    name: vmJumpName 
    vmSize: vmJumpSize
    adminUsername: vmJumpAdminUsername
    adminPassword: vmJumpAdminPassword
    nicName: nicJumpName
  }
}

module publicIpDnsResources '../modules/Microsoft.Network/publicIp.bicep' = if (deployPublicIpDns) {
  name: 'publicIpDnsResources_Deploy'
  params: {
    location: location
    tags: tags
    name: publicIpDnsName
  }
}

module nsgDnsNicResources '../modules/Microsoft.Network/nsg.bicep' = {
  name: 'nsgDnsNicResources_Deploy'
  params: {
    location: location
    tags: tags
    name: nsgDnsNicName
    snetInfo: {}
  }
}

module nicDnsResources '../modules/Microsoft.Network/nic.bicep' = {
  name: 'nicDnsResources_Deploy'
  params: {
    location: location
    tags: tags
    name: nicDnsName 
    snetName: subnetDnsName
    networkingResourceGroupName: networkingResourceGroupName
    deployPublicIp: deployPublicIpDns
    publicIpName: publicIpDnsName
    nsgName: nsgDnsNicName 
  }
}


module vmDnsResources '../modules/Microsoft.Compute/vm.bicep' = {
  name: 'DnsVmcResources_Deploy'
  params: {
    location: location
    tags: tags
    name: vmDnsName 
    vmSize: vmDnsSize
    adminUsername: vmDnsAdminUsername
    adminPassword: vmDnsAdminPassword
    nicName: nicDnsName
  }
}



