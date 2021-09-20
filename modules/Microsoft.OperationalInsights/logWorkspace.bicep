@description('Location of the resources')
param location string = resourceGroup().location
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
@description('Name for Log Analytics Workspace')
param name string = 'wvd-${toLower(environment)}-workspace'


resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output workspaceName string = logWorkspace.name
