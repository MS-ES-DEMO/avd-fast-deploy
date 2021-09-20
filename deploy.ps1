# Warning: Running this script multiple times will cause the admin

$deploymentName="AWVD-Deployment-$(New-Guid)"


# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.
az deployment sub create -l westeurope -n $deploymentName --template-file '.\main.bicep' --parameters .\parameters.json