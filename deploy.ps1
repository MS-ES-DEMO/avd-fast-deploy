# Warning: Change parameters file based on desired deployment type: personal or pooled scenario
# Warning: Running this script multiple times will cause the admin
# password for the session host to be changed. Be sure to change the parameters file properly.

Import-Module Tools

$deploymentName="AVD-PRE-Data-Pooled-Deployment"
#$deploymentName="AVD-PRE-Data-Pers-Deployment"
#$deploymentName="AVD-PRE-Oper-Pooled-Deployment"
#$deploymentName="AVD-PRE-Oper-Pers-Deployment"

#$localVmAdminPassword = randomPassword
$localVmAdminPassword = 'x6zJgL4pcwF]w/4ccpjtcgaAtz]cij48e' 


#$localVmAdminPassword = '7eVNqvRbCzmXwkUTK_vD8SKl5xsE'#rg-avd-prod-001 personal
#$localVmAdminPassword = 'x6zJgL4pcwF]w/4ccpjtcgaAtz]cij48e'#rg-avd-prod-001 pooled
$existingDomainAdminPassword = 'XgXqIlT6LYBydGnhvKd\cue/9q5k'#TODO: ONLY FOR TESTING PURPOSES
#$existingDomainAdminPassword = 'S1stemcenteravd2021' #virtualdom

$params = "{ \`"localVmAdminPassword\`":{\`"value\`": \`"${localVmAdminPassword}\`" }, \`"existingDomainAdminPassword\`":{\`"value\`": \`"${existingDomainAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file is up to date
# TODO: For production deployments, update the deployment parameter file in the command below.

#az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\personal.parameters.json' --parameters $params
az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\pooled.parameters.json' --parameters $params
#az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\personal.parameters.virtualdom.json' --parameters $params
#az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\pooled.parameters.virtualdom.json' --parameters $params