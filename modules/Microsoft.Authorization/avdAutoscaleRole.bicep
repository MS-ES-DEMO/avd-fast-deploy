
param name string 

var actions = [ 
  'Microsoft.Insights/eventtypes/values/read'
  'Microsoft.Compute/virtualMachines/deallocate/action'
  'Microsoft.Compute/virtualMachines/restart/action'
  'Microsoft.Compute/virtualMachines/powerOff/action'
  'Microsoft.Compute/virtualMachines/start/action'
  'Microsoft.Compute/virtualMachines/read'
  'Microsoft.DesktopVirtualization/hostpools/read'
  'Microsoft.DesktopVirtualization/hostpools/write'
  'Microsoft.DesktopVirtualization/hostpools/sessionhosts/read'
  'Microsoft.DesktopVirtualization/hostpools/sessionhosts/write'
  'Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/delete'
  'Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read'
  'Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/sendMessage/action'
  'Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read'
]
var roleDefName = guid(subscription().id, string(actions))


resource role 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: roleDefName
  properties: {
    roleName: name
    type: 'customRole'
    assignableScopes: [ 
      '/subscriptions/${subscription().id}' 
    ]
    description: 'This role will allow Windows Virtual Desktop to power manage all VMs in this subscription.'
    permissions: [
      {
        actions: actions
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
  }
}

// az ad sp show --id 26da2792-4d23-4313-b9e7-60bd7c1bf0b1 to get principalId
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: '${name}Assignment'
  properties: {
    principalId: '9cdead84-a844-4324-93f2-b2e6bb768d07'
    principalType: 'ServicePrincipal'
    roleDefinitionId: role.id
  }
}
