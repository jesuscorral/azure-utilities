function Add-IpToFirewall {
    param (
        [string]$serverName,
        [string]$resourceGroupName,
        [string]$firewallRuleName,
        [string]$ipAddress
    )

    $server = Get-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $serverName

    # Check if the firewall rule already exists
    $existingFirewallRule = Get-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName $firewallRuleName -ErrorAction SilentlyContinue

    if ($existingFirewallRule) {
        # Update existing firewall rule
        Set-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName $firewallRuleName -StartIpAddress $ipAddress -EndIpAddress $ipAddress
    }
    else {
        # Create new firewall rule
        New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName $firewallRuleName -StartIpAddress $ipAddress -EndIpAddress $ipAddress
    }

}
