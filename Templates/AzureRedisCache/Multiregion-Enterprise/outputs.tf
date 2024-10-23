
output "PUBLIC_IP_ADDRESS" { 
  value =  [ for region in azurerm_public_ip.linux : region.ip_address ]
  sensitive = false  
}

output "REDIS_HOSTS" { 
  value =  [ for region in azurerm_redis_enterprise_cluster.this : region.hostname ]
  sensitive = false  
}

output "REDIS_ACCESS_KEYS" { 
  value = [ for region in data.azurerm_redis_enterprise_database.cluster_instance : region.primary_access_key ]
  sensitive = true
}
