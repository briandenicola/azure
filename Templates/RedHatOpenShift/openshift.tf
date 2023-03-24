resource "azapi_resource" "aro_cluster" {
  name      = local.aro_name
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  type      = "Microsoft.RedHatOpenShift/openShiftClusters@2022-04-01"

  body = jsonencode({
    properties = {
      clusterProfile = {
        domain               = var.domain
        fipsValidatedModules = "Disabled"
        resourceGroupId      = local.resource_group_id
      }
      networkProfile = {
        podCidr              = "100.${random_integer.pod_cidr.id}.0.0/16"
        serviceCidr          = "100.${random_integer.services_cidr.id}.0.0/16"
      }
      servicePrincipalProfile = {
        clientId             = azuread_service_principal.this.object_id
        clientSecret         = azuread_application_password.this.value
      }
      masterProfile = {
        vmSize               = "Standard_D8s_v3"
        subnetId             = azurerm_subnet.master_subnet.id
        encryptionAtHost     = "Disabled"
      }
      workerProfiles = [
        {
          name               = "worker"
          vmSize             = "Standard_D4s_v3"
          diskSizeGB         = 128
          subnetId           = azurerm_subnet.worker_subnet.id
          count              = 3
          encryptionAtHost   = "Disabled"
        }
      ]
      apiserverProfile = {
        visibility           = "Public"
      }
      ingressProfiles = [
        {
          name               = "default"
          visibility         = "Public"
        }
      ]
    }
  })

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}