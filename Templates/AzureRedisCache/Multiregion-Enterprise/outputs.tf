
output "PUBLIC_IP_ADDRESSES" { 
  value = [ for region in azurerm_public_ip.linux : region.ip_address ]
}

output "REDIS_HOSTS" { 
  value = [ for region in azurerm_redis_enterprise_cluster.this : region.hostname  ]
}

output "REDIS_ACCESS_KEY" { 
  value = azurerm_redis_enterprise_database.this.primary_access_key   
  sensitive = true
}