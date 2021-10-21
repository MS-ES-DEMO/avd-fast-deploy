# Warning: Change parameters file based on desired deployment type: personal or pooled scenario


Import-Module Tools
randomPassword

$deploymentName="AWVD-Deployment-$(New-Guid)"

$localVmAdminUsername = 'localVmAdmin'
$localVmAdminPassword = randomPassword

$existingDomainAdminName = 'addsdnsadmin'
$existingDomainAdminPassword = randomPassword

$params = "{ \`"localVmAdminUsername\`":{\`"value\`": \`"${localVmAdminUsername}\`" }, \`"localVmAdminPassword\`":{\`"value\`": \`"${localVmAdminPassword}\`" }, \`"existingDomainAdminName\`":{\`"value\`": \`"${existingDomainAdminName}\`" }, \`"existingDomainAdminPassword\`":{\`"value\`": \`"${existingDomainAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.
az deployment sub create -l westeurope -n $deploymentName --template-file '.\awvd\main.bicep' --parameters '.\pooled.parameters.json' --parameters $params