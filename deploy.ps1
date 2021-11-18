# Warning: Change parameters file based on desired deployment type: personal or pooled scenario
# Warning: Running this script multiple times will cause the admin
# password for the session host to be changed. Be sure to change the parameters file properly.

Import-Module Tools

$deploymentName="AVD-Deployment-$(New-Guid)"

$localVmAdminPassword = randomPassword
$existingDomainAdminPassword = randomPassword 

$params = "{ \`"localVmAdminPassword\`":{\`"value\`": \`"${localVmAdminPassword}\`" }, \`"existingDomainAdminPassword\`":{\`"value\`": \`"${existingDomainAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.

az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\pooled.parameters.json' --parameters $params