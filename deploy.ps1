# Warning: Change parameters file based on desired deployment type: personal or pooled scenario
# Warning: Running this script multiple times will cause the admin
# password for the session host to be changed. Be sure to change the parameters file properly.

Import-Module Tools

$deploymentName="AVD-Deployment-$(New-Guid)"

$localVmAdminPassword = randomPassword
#$existingDomainAdminPassword = 'XgXqIlT6LYBydGnhvKd\cue/9q5k'#TODO: ONLY FOR TESTING PURPOSES

$existingDomainAdminPassword = 'S1stemcenteravd2021'

$params = "{ \`"localVmAdminPassword\`":{\`"value\`": \`"${localVmAdminPassword}\`" }, \`"existingDomainAdminPassword\`":{\`"value\`": \`"${existingDomainAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file is up to date
# TODO: For production deployments, update the deployment parameter file in the command below.

az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\personal.parameters.virtualdom.json' --parameters $params