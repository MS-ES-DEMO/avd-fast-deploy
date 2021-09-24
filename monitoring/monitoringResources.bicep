
// TODO: verify the required parameters

// Global Parameters
param location string = resourceGroup().location
param env string
param tags object
//@description('Name for Monitoring RG')
//param monitoringResourceGroupName string
param deployLogWorkspace bool
param existingLogWorkspaceName string

var logWorkspaceName = 'workspace-${toLower(env)}-awvd'

module logWorkspaceResources '../modules/Microsoft.OperationalInsights/logWorkspace.bicep' = if (deployLogWorkspace) {
  //scope: resourceGroup(monitoringResourceGroupName)
  name: 'logWorkspaceResources_Deploy'
  params: {
    location: location
    tags: tags
    name: logWorkspaceName
  }
}

resource existingWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!deployLogWorkspace) {
  name: existingLogWorkspaceName
}

/* Section: Log Analytics Solutions */

//TODO: Complete this section

output logWorkspaceName string = deployLogWorkspace ? logWorkspaceResources.outputs.workspaceName : existingLogWorkspaceName
