# Warning: Change parameters file based on desired deployment type: personal or pooled scenario
# Warning: Running this script multiple times will cause the admin
# password for the session host to be changed. Be sure to change the parameters variables properly.

Import-Module Tools # Comment if you prefer to set up the localVmAdminPassword parameter manually.

$deploymentName="AVD-PRE-Data-Pooled-Deployment"
#$deploymentName="AVD-PRE-Data-Pers-Deployment"
#$deploymentName="AVD-PRE-Oper-Pooled-Deployment"
#$deploymentName="AVD-PRE-Oper-Pers-Deployment"

$localVmAdminPassword = randomPassword # Comment wheter you prefer to set up this parameter manually or are running this script multiple times.



#$localVmAdminPassword = '7eVNqvRbCzmXwkUTK_vD8SKl5xsE'#rg-avd-prod-001 personal
#$localVmAdminPassword = 'x6zJgL4pcwF]w/4ccpjtcgaAtz]cij48e'#rg-avd-prod-001 pooled
#$existingDomainAdminPassword = 'XgXqIlT6LYBydGnhvKd\cue/9q5k'#TODO: ONLY FOR TESTING PURPOSES
#$existingDomainAdminPassword = 'S1stemcenteravd2021' #virtualdom

$params = "{ \`"localVmAdminPassword\`":{\`"value\`": \`"${localVmAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# Ensure the parameters.json file is up to date
# For production deployments, update the deployment parameter file in the command below.
# Uncomment the following lines based on your scenario

#az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\personal.parameters.json' --parameters $params
az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\pooled.parameters.json' --parameters $params
#az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\personal.parameters.virtualdom.json' --parameters $params
#az deployment sub create -l westeurope -n $deploymentName --template-file '.\avd\main.bicep' --parameters '.\pooled.parameters.virtualdom.json' --parameters $params