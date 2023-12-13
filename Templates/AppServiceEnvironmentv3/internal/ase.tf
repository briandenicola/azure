resource "azurerm_app_service_environment_v3" "this" {
  name                          	        = "${local.ase_name}"
  resource_group_name                     = azurerm_resource_group.this.name
  subnet_id                               = azurerm_subnet.ase.id
  internal_load_balancing_mode            = "Web, Publishing" 
  allow_new_private_endpoint_connections  = false
  zone_redundant                          = false 

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }
}

resource "azurerm_service_plan" "app_service_plan_windows" {
  name                         = "${local.resource_name}-windows-hosting"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  os_type                      = "Windows"
  app_service_environment_id   = azurerm_app_service_environment_v3.this.id
  sku_name                     = "I4v2"
  worker_count                 = 3
}

resource "azurerm_service_plan" "app_service_plan_linux" {
  name                         = "${local.resource_name}-linux-hosting"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  os_type                      = "Linux"
  app_service_environment_id   = azurerm_app_service_environment_v3.this.id
  sku_name                     = "I2v2"
  worker_count                 = 3
}

resource "azurerm_windows_web_app" "windows_webapp" {
  name                = "01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.app_service_plan_windows.id

  identity {
    type = "SystemAssigned"
  }
  
  site_config {
    application_stack  {
      dotnet_version = "v6.0"
    }
  }
}

resource "azurerm_linux_web_app" "linux_webapp" {
  name                = "02"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.app_service_plan_linux.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true

    application_stack  {
      docker_image_name = "bjdcsa.azurecr.io/httpdemo:1287"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "8080"
  }
}
