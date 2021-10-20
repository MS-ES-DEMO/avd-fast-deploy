# Warning: Change deploymentName for a new awvd scenario


$deploymentName="AWVD-Deployment-$(New-Guid)"

$localVmAdminPassword = 'localVmAdmin123$'
$localVmAdminUsername = 'localVmAdmin'
$existingDomainAdminName = 'dnsadmin'
$existingDomainAdminPassword = 'dnsadmin123$'

$params = "{ \`"localVmAdminUsername\`":{\`"value\`": \`"${localVmAdminUsername}\`" }, \`"localVmAdminPassword\`":{\`"value\`": \`"${localVmAdminPassword}\`" }, \`"existingDomainAdminName\`":{\`"value\`": \`"${existingDomainAdminName}\`" }, \`"existingDomainAdminPassword\`":{\`"value\`": \`"${existingDomainAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.
az deployment sub create -l westeurope -n $deploymentName --template-file '.\awvd\main.bicep' --parameters '.\personal.parameters.json' --parameters $params