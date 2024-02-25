# Parameters
$resourceGroupName = "" #TODO: Fill in the resource group name # Resource Group Name
$subscriptionId = "" #TODO: Fill in the subscription id
$user = "" #TODO Fill with your user # User to add to the authorization

# Connect to Azure
Write-Host "Connecting to Azure..."
Connect-AzAccount
Set-AzContext -SubscriptionId $subscriptionId

# Key Vault Parameters
$keyVaults = @("sds2-core-dev1-kva", "sds2-dev1-kva", "sds2-dev1-shared-kva")

# Get the current user's object ID
$currentUser = az ad signed-in-user show | ConvertFrom-Json
$userObjectId = $currentUser.id

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$functionsDir = Join-Path -Path $scriptDir -ChildPath "Functions"
Write-Host "scriptDir: $scriptDir"
Write-Host "functionsDir: $functionsDir"
. (Join-Path $functionsDir -ChildPath "add-access-policy-to-keyvault.ps1")
. (Join-Path $functionsDir -ChildPath "add-ip-to-firewall.ps1")
. (Join-Path $functionsDir -ChildPath "add-ip-to-keyvault-networking.ps1")
. (Join-Path $functionsDir -ChildPath "get-secrets-from-keyvault.ps1")
. (Join-Path $functionsDir -ChildPath "add-user-to-authorization.ps1")

Write-Host "Getting current IP address..."
# Get current IP address
$ipAddress = Invoke-RestMethod -Uri "https://api.ipify.org?format=json" | Select-Object -ExpandProperty ip

Write-Host "Adding IP to SQL Server firewall..."
Add-IpToFirewall -resourceGroupName $resourceGroupName -subscriptionId $subscriptionId -firewallRuleName $user -ipAddress $ipAddress

foreach ($keyVaultName in $keyVaults) {
    Write-Host "Adding access policy to key vault $keyVaultName..."
    Add-AccessPolicyToKeyVault -keyVaultName $keyVaultName -userObjectId $userObjectId
    Write-Host "Adding IP to networking key vault $keyVaultName..."
    Add-IpToNetworkingKeyVault -keyVaultName $keyVaultName -ipAddress $ipAddress
}

$coreContextConnectionString = Get-SecretFromKeyVault -SubscriptionId $subscriptionId -KeyVaultName "sds2-core-dev1-kva" -SecretName "ConnectionStrings--CoreContext"
$SwaggerCoreApiClient = Get-SecretFromKeyVault -SubscriptionId $subscriptionId -KeyVaultName "sds2-core-dev1-kva" -SecretName "ClientSettings--SwaggerCoreApiClient--ClientId"

$coreContextConnectionStringValue = $coreContextConnectionString[1]
$SwaggerCoreApiClientValue = $SwaggerCoreApiClient[1]

Add-UserToAuthorization -ConnectionString $coreContextConnectionStringValue -User $user

$summaryContainers = az containerapp list --resource-group $resourceGroupName --query "[].{name:name, status:properties.runningStatus, image:properties.template.containers[0].image, minReplicas:properties.template.scale.minReplicas, maxReplicas:properties.template.scale.maxReplicas}" --output table

Write-Host "--------- Summary Containers --------- "
$summaryContainers | Format-Table

Write-Host "--------------- Secrets ---------------"
Write-Host "CoreContext Connection String: $coreContextConnectionStringValue"
Write-Host "SwaggerCoreApiClient: $SwaggerCoreApiClientValue"
Write-Host "--------------------------------------"

# Disconnect from Azure
Disconnect-AzAccount

