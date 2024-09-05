data "azurerm_app_service_environment_v3" "this" {
  name                = local.ase_name
  resource_group_name = local.ase_rg_name
}

data "azurerm_service_plan" "app_service_plan_windows" {
  name                = "${var.ase_app_name}-windows-hosting"
  resource_group_name = local.ase_rg_name
}
