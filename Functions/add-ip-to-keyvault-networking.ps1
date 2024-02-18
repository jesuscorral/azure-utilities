function Add-IpToNetworkingKeyVault {
    param (
        [Parameter(Mandatory = $true)]
        [string]$keyVaultName,

        [Parameter(Mandatory = $true)]
        [string]$resourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]$ipAddress
    )

    # Import the AzureRM module
    Import-Module Az.KeyVault

    # Add your IP address to the Key Vault firewall rules
    Set-AzKeyVaultNetworkRuleSet -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Bypass AzureServices -DefaultAction Deny -IpAddressRange $ipAddress

}