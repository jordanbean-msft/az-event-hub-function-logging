terraform {
  required_providers {
    azurerm = {
      version = "~>4.14.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy Storage Account
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "storage_account_name" {
  name          = var.resource_token
  resource_type = "azurerm_storage_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_storage_account" "storage_account" {
  name                            = azurecaf_name.storage_account_name.result
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  tags                            = var.tags
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "function_app_container" {
  name               = "siem-logging"
  storage_account_id = azurerm_storage_account.storage_account.id
}

resource "azurerm_role_assignment" "managed_identity_storage_blob_data_owner_role" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.managed_identity_principal_id
}
