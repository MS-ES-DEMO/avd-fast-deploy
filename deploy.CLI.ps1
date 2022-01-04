param (
  [string]
  $location = "westeurope",
  [string] 
  $templateFile = ".\avd\main.bicep",
  [string]
  $parameterFile = "parameters.pooled.json",
  [string] 
  $deploymentPrefix='AVD-Data-Pooled-Deployment'
  )

$deploymentName = $deploymentPrefix

az deployment sub create -l westeurope -n $deploymentName --template-file $templateFile --parameters $parameterFile 
