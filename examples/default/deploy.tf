resource "random_string" "this" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_resource_group" "example" {
  name     = "tftest${random_string.this.result}"
  location = "West Europe"
  tags = {
    test = "tftest${random_string.this.result}"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "storage${random_string.this.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example" {
  name                = "plan${random_string.this.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

module "azure_function" {
  source = "../../"

  resource_group_name                                    = azurerm_resource_group.example.name
  location                                               = azurerm_resource_group.example.location
  function_app_name                                      = "function"
  function_app_plan_id                                   = azurerm_app_service_plan.example.id
  function_app_storage_account_name                      = azurerm_storage_account.example.name
  function_app_storage_account_primary_connection_string = azurerm_storage_account.example.primary_connection_string
  function_app_storage_account_primary_access_key        = azurerm_storage_account.example.primary_access_key


  tags = {
    Terratest = "true"
  }

  depends_on = [azurerm_resource_group.example, azurerm_app_service_plan.example, azurerm_storage_account.example]

}
