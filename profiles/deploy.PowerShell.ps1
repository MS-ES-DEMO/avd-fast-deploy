param (
  [string]
  $location = "westeurope",
  [string] 
  $templateFile = ".\main.bicep",
  [string]
  $parameterFile = "parameters.pooled.json",
  [string] 
  $deploymentPrefix='AVD-Profiles-Deployment'
  )

$deploymentName = $deploymentPrefix


New-AzDeployment -Name $deploymentName `
                -Location $location `
                -TemplateFile $templateFile `
                -TemplateParameterFile $parameterFile `
                -Verbose

