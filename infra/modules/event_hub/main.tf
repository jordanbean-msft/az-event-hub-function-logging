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
# Deploy event hub
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "event_hub_namespace_name" {
  name          = var.resource_token
  resource_type = "azurerm_eventhub_namespace"
  random_length = 0
  clean_input   = true
}

resource "azurerm_eventhub_namespace" "event_hub_namespace" {
  name                          = azurecaf_name.event_hub_namespace_name.result
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.event_hub_namespace_sku
  capacity                      = var.capacity
  auto_inflate_enabled          = true
  maximum_throughput_units      = var.maximum_throughput_units
  tags                          = var.tags
  public_network_access_enabled = true
}

resource "azurerm_eventhub" "event_hub_central" {
  name              = "central-logging"
  namespace_id      = azurerm_eventhub_namespace.event_hub_namespace.id
  partition_count   = var.partition_count
  message_retention = var.message_retention
}

resource "azurerm_eventhub" "event_hub_siem" {
  name              = "siem-logging"
  namespace_id      = azurerm_eventhub_namespace.event_hub_namespace.id
  partition_count   = var.partition_count
  message_retention = var.message_retention
}

resource "azurerm_eventhub_consumer_group" "central_logging_replication" {
  name                = "central-logging-replication"
  eventhub_name       = azurerm_eventhub.event_hub_central.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_consumer_group" "central_siem_replication" {
  name                = "central-siem-replication"
  eventhub_name       = azurerm_eventhub.event_hub_central.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_consumer_group" "siem_logging" {
  name                = "siem-logging"
  eventhub_name       = azurerm_eventhub.event_hub_siem.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "managed_identity_azure_event_hubs_data_sender_role" {
  scope                = azurerm_eventhub_namespace.event_hub_namespace.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = var.managed_identity_principal_id
}

resource "azurerm_role_assignment" "managed_identity_azure_event_hubs_data_receiver_role" {
  scope                = azurerm_eventhub_namespace.event_hub_namespace.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = var.managed_identity_principal_id
}

resource "azurerm_eventhub_namespace_authorization_rule" "azure_policy_central_logging_event_hub_authorization_rule" {
  name                = "azure-policy-central-logging"
  namespace_name      = azurerm_eventhub_namespace.event_hub_namespace.name
  resource_group_name = var.resource_group_name
  send                = true
  listen              = true
  manage              = true
}

resource "azurerm_monitor_diagnostic_setting" "event_hub_logging" {
  name                       = "event-hub-logging"
  target_resource_id         = azurerm_eventhub_namespace.event_hub_namespace.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationMetricsLogs"
  }

  enabled_log {
    category = "ArchiveLogs"
  }

  enabled_log {
    category = "AutoScaleLogs"
  }

  enabled_log {
    category = "CustomerManagedKeyUserLogs"
  }

  enabled_log {
    category = "DataDRLogs"
  }

  enabled_log {
    category = "DiagnosticErrorLogs"
  }

  enabled_log {
    category = "EventHubVNetConnectionEvent"
  }

  enabled_log {
    category = "KafkaCoordinatorLogs"
  }

  enabled_log {
    category = "KafkaUserErrorLogs"
  }

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "RuntimeAuditLogs"
  }

  metric {
    category = "AllMetrics"
  }
}