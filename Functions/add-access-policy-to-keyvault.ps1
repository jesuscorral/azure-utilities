# Add-AccessPolicyToKeyVault function
function Add-AccessPolicyToKeyVault {
    param (
        [Parameter(Mandatory = $true)]
        [string]$keyVaultName,

        [Parameter(Mandatory = $true)]
        [string]$userObjectId
    )
    Set-AzKeyVaultAccessPolicy -ObjectId $userObjectId -VaultName $keyVaultName -PermissionsToSecrets get,list,set
}

