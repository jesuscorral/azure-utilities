function Get-SecretFromKeyVault {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory=$true)]
        [string]$KeyVaultName,
        
        [Parameter(Mandatory=$true)]
        [string]$SecretName
    )
    
    # Import the AzureRM module
    Import-Module Az
    
    # Set the Azure subscription context
    Set-AzContext -SubscriptionId $SubscriptionId
    
    # Get the secret from the Key Vault
    $Secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName
    
    # Return the secret value
    return $Secret.SecretValue | ConvertFrom-SecureString -AsPlainText
}
