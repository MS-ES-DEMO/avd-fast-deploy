@description('Location of the resources')
param location string = resourceGroup().location
@description('Deploy Log Analytics Workspace?')
param deployLogWorkspace bool
@description('Name for existing Log Analytics Workspace')
param existingLogWorkspaceName string
@description('Project Tags')
param tags object
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

//TODO: Confirm naming
var logWorkspaceName = 'wvd-${toLower(environment)}-workspace'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = if (deployLogWorkspace) {
  name: logWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource existingWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!deployLogWorkspace) {
  name: existingLogWorkspaceName
}

/* Section: Log Analytics Solutions */

//TODO: Complete this section

output newWorkspaceName string = deployLogWorkspace ? logWorkspace.name : ''
