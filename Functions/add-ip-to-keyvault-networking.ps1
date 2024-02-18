function Add-IpToNetworkingKeyVault {
    param (
        [Parameter(Mandatory = $true)]
        [string]$keyVaultName,

        [Parameter(Mandatory = $true)]
        [string]$ipAddress
    )

    # Import the AzureRM module
    Import-Module Az.KeyVault

    # Add your IP address to the Key Vault firewall rules
    Add-AzKeyVaultNetworkRule -VaultName $keyVaultName -IpAddressRange $ipAddress

}