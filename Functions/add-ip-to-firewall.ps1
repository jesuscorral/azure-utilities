function Add-IpToFirewall {
    param (
        [string]$resourceGroupName,
        [string]$firewallRuleName,
        [string]$ipAddress
    )

# Get the SQL servers in the resource group
$servers = Get-AzSqlServer -ResourceGroupName $resourceGroupName

# Iterate through the servers
foreach ($server in $servers) {
    $serverName = $server.ServerName
    Write-Host "SQL Server Name: $($serverName)"
   
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


   

}
