

resource "azurerm_automation_account" "this" {
  name                = local.automation_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "Basic"
}

resource "azurerm_automation_hybrid_runbook_worker_group" "this" {
  name                    = "${local.automation_name}-workers"
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
}

resource "azurerm_automation_hybrid_runbook_worker" "this" {
  count                   = var.number_of_runners
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  worker_group_name       = azurerm_automation_hybrid_runbook_worker_group.this.name
  vm_resource_id          = azurerm_linux_virtual_machine.this[count.index].id
  worker_id               = random_uuid.id[count.index].result 
}