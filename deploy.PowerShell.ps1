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


New-AzDeployment -Name $deploymentName `
                -Location $location `
                -TemplateFile $templateFile `
                -TemplateParameterFile $parameterFile `
                -Verbose

