# Warning: Change parameters file based on desired deployment type: personal or pooled scenario
# Warning: Running this script multiple times will cause the admin
# password for the session host to be changed. Be sure to change the parameters file properly.

Import-Module Tools

$deploymentName="AVD-Deployment-$(New-Guid)"

#$localVmAdminPassword = randomPassword
$localVmAdminPassword = 'Rq/29lATmDy^AuOM//DxHuxDqm'

$existingDomainAdminName = 'addsdnsadmin'
$existingDomainAdminPassword = 'G6vOWZ1DrmUZaAP0maOgWJhDMAAkS5z' #TODO: Remove

$params = "{ \`"localVmAdminPassword\`":{\`"value\`": \`"${localVmAdminPassword}\`" }, \`"existingDomainAdminName\`":{\`"value\`": \`"${existingDomainAdminName}\`" }, \`"existingDomainAdminPassword\`":{\`"value\`": \`"${existingDomainAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.

az deployment sub create -l westeurope -n $deploymentName --template-file '.\awvd\main.bicep' --parameters '.\personal.parameters.json' --parameters $params