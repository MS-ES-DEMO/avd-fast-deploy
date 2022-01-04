param (
  [Parameter(Mandatory = $true)]
  [string]
  $adminPassword,
  [string]
  $location = "westeurope",
  [string] 
  $templateFile = ".\avd\main.bicep",
  [string]
  $parameterFile = "parameters.personal.json",
  [string] 
  $deploymentPrefix='AVD-Data-Pooled-Deployment'
  )

$deploymentName = $deploymentPrefix


$params = "{ \`"localVmAdminPassword\`":{\`"value\`": \`"${adminPassword}\`" } }"

az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\pooled.parameters.json' --parameters $params
