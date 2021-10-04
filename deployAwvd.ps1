# Warning: Change deploymentName for a new awvd scenario


$deploymentName="AWVD-Deployment-$(New-Guid)"

$params = "{ \`"vmJumpAdminPassword\`":{\`"value\`": \`"${vmJumpAdminPassword}\`" }, \`"vmDnsAdminPassword\`":{\`"value\`": \`"${vmDnsAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.
az deployment sub create -l westeurope -n $deploymentName --template-file '.\layers\main.bicep' --parameters '.\awvd\awvd.parameters.json' --parameters $params