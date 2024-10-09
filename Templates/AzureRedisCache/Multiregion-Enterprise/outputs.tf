
output "PUBLIC_IP_ADDRESS_1" { 
  value =  azurerm_public_ip.linux[element(var.regions, 0)].ip_address
  sensitive = false  
}

output "REDIS_HOST_1" { 
  value =  azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].hostname
  sensitive = false  
}

output "PUBLIC_IP_ADDRESS_2" { 
  value =  azurerm_public_ip.linux[element(var.regions, 1)].ip_address
  sensitive = false
}

output "REDIS_HOST_2" { 
  value =  azurerm_redis_enterprise_cluster.this[element(var.regions, 1)].hostname
  sensitive = false
}

output "REDIS_ACCESS_KEY_1" { 
  value = data.azurerm_redis_enterprise_database.region_1_cluster_instance.primary_access_key   
  sensitive = true
}

output "REDIS_ACCESS_KEY_2" { 
  value = data.azurerm_redis_enterprise_database.region_2_cluster_instance.primary_access_key   
  sensitive = true
}