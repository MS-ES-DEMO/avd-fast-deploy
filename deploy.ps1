# Warning: Running this script multiple times will cause the admin


Add-Type -AssemblyName System.Web
do {
    $vmJumpAdminPassword = [System.Web.Security.Membership]::GeneratePassword(32,5)
} while ($vmJumpAdminPassword -inotmatch "&" -and $vmJumpAdminPassword -inotmatch "%" -and $vmJumpAdminPassword -inotmatch "|")

Add-Type -AssemblyName System.Web
do {
    $vmAddsAdminPassword = [System.Web.Security.Membership]::GeneratePassword(32,5)
} while ($vmAddsAdminPassword -inotmatch "&" -and $vmAddsAdminPassword -inotmatch "%" -and $vmAddsAdminPassword -inotmatch "|")

$deploymentName="AWVD-Deployment-$(New-Guid)"

$params = "{ \`"vmJumpAdminPassword\`":{\`"value\`": \`"${vmJumpAdminPassword}\`" }, \`"vmAddsAdminPassword\`":{\`"value\`": \`"${vmAddsAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.
az deployment sub create -l westeurope -n $deploymentName --template-file '.\main.bicep' --parameters .\parameters.json --parameters $params