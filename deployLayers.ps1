# Warning: Running this script multiple times will cause the admin
# password for the VMs to be changed.

#Import-Module -Name "D:\test.psm1"
#Add-Type -AssemblyName System.Web
#
#do {
#    $vmJumpAdminPassword = [System.Web.Security.Membership]::GeneratePassword(32,5)
#} while ($vmJumpAdminPassword -inotmatch "&" -and $vmJumpAdminPassword -inotmatch "%" -and $vmJumpAdminPassword -inotmatch "|")
#
#do {
#    $vmDnsAdminPassword = [System.Web.Security.Membership]::GeneratePassword(32,5)
#} while ($vmDnsAdminPassword -inotmatch "&" -and $vmDnsAdminPassword -inotmatch "%" -and $vmDnsAdminPassword -inotmatch "|")

#$symbols = '!@#$%^&*'.ToCharArray()
#$characterList = 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols
#function GeneratePassword {
#    param(
#        [Parameter(Mandatory = $false)]
#        [ValidateRange(12, 256)]
#        [int] 
#        $length = 14
#    )
#    
#    do {
#        $password = ""
#        for ($i = 0; $i -lt $length; $i++) {
#            $randomIndex = [System.Security.Cryptography.RandomNumberGenerator]::GetInt32(0, $characterList.Length)
#            $password += $characterList[$randomIndex]
#        }
#
#        [int]$hasLowerChar = $password -cmatch '[a-z]'
#        [int]$hasUpperChar = $password -cmatch '[A-Z]'
#        [int]$hasDigit = $password -match '[0-9]'
#        [int]$hasSymbol = $password.IndexOfAny($symbols) -ne -1
#
#    }
#    until (($hasLowerChar + $hasUpperChar + $hasDigit + $hasSymbol) -ge 3)
#    
#    $password | ConvertTo-SecureString -AsPlainText
#}
#
#$vmJumpAdminPassword = GeneratePassword
$vmJumpAdminPassword = 'jumpadmin123$'
$vmDnsAdminPassword = 'dnsadmin123$'

$deploymentName="Layers-Deployment-$(New-Guid)"

$params = "{ \`"vmJumpAdminPassword\`":{\`"value\`": \`"${vmJumpAdminPassword}\`" }, \`"vmDnsAdminPassword\`":{\`"value\`": \`"${vmDnsAdminPassword}\`" } }"

# The deployment is applied at the subscription scope
# TODO: Ensure the parameters.json file us up to date
# TODO: For production deployments, update the deployment parameter file in the command below.
az deployment sub create -l westeurope -n $deploymentName --template-file '.\layers\main.bicep' --parameters '.\layers\layers.parameters.json' --parameters $params