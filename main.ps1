# Firewall Parameters
$serverName = "" #TODO: Fill in the server name
$resourceGroupName = "" #TODO: Fill in the resource group name
$subscriptionId = "" #TODO: Fill in the subscription id
$firewallRuleName = "" #TODO: Fill in the firewall rule name

# Key Vault Parameters
$userObjectId = "" #TODO: Fill in the user object id
$keyVaults = @("", "", "") #TODO: Fill in the key vault names

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$functionsDir = Join-Path -Path $scriptDir -ChildPath "Functions"
Write-Host "scriptDir: $scriptDir"
Write-Host "functionsDir: $functionsDir"
. (Join-Path $functionsDir -ChildPath "add-access-policy-to-keyvault.ps1")
. (Join-Path $functionsDir -ChildPath "add-ip-to-firewall.ps1")
. (Join-Path $functionsDir -ChildPath "add-ip-to-keyvault-networking.ps1")

# Connect to Azure
Write-Host "Connecting to Azure..."
Connect-AzAccount
Set-AzContext -SubscriptionId $subscriptionId

Write-Host "Getting current IP address..."
# Get current IP address
$ipAddress = Invoke-RestMethod -Uri "https://api.ipify.org?format=json" | Select-Object -ExpandProperty ip

Write-Host "Adding IP to firewall..."
Add-IpToFirewall -serverName $serverName -resourceGroupName $resourceGroupName -subscriptionId $subscriptionId -firewallRuleName $firewallRuleName -ipAddress $ipAddress

foreach ($keyVaultName in $keyVaults) {
    Write-Host "Adding access policy to key vault $keyVaultName..."
    Add-AccessPolicyToKeyVault -keyVaultName $keyVaultName -userObjectId $userObjectId
    Write-Host "Adding IP to networking key vault $keyVaultName..."
    Add-IpToNetworkingKeyVault -keyVaultName $keyVaultName -ipAddress $ipAddress
}


# Disconnect from Azure
Disconnect-AzAccount