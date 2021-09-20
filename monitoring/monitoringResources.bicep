
// TODO: verify the required parameters

// Global Parameters
@description('Location of the resources')
param location string = resourceGroup().location
@description('Environment: Dev,Test,PreProd,Uat,Prod,ProdDr.')
@allowed([
  'Dev'
  'Test'
  'PreProd'
  'Uat'
  'Prod'
  'ProdDr'
])
param environment string
@description('Project Tags')
param tags object
//@description('Name for Monitoring RG')
//param monitoringResourceGroupName string
@description('Deploy Log Analytics Workspace?')
param deployLogWorkspace bool
@description('Name for existing Log Analytics Workspace')
param existingLogWorkspaceName string

var logWorkspaceName = 'workspace-${toLower(environment)}-awvd'

module logWorkspaceResources '../modules/Microsoft.OperationalInsights/logWorkspace.bicep' = if (deployLogWorkspace) {
  //scope: resourceGroup(monitoringResourceGroupName)
  name: 'logWorkspaceResources_Deploy'
  params: {
    location: location
    environment: environment
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
