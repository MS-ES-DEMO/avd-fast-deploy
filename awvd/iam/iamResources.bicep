
targetScope = 'subscription'

// TODO: verify the required parameters

// Global Parameters

param name string 

module avdAutoscaleRoleResources '../../modules/Microsoft.Authorization/avdAutoscaleRole.bicep' = {
  name: 'avdAutoscaleRole_Deploy'
  params: {
    name: name
  }
}

