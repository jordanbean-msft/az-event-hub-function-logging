output "event_hub_namespace_name" {
  value = azurerm_eventhub_namespace.event_hub_namespace.name
}

output "event_hub_central_name" {
  value = azurerm_eventhub.event_hub_central.name
}

output "event_hub_siem_name" {
  value = azurerm_eventhub.event_hub_siem.name
}

output "event_hub_consumer_group_central_siem_replication" {
  value = azurerm_eventhub_consumer_group.central_siem_replication.name
}

output "event_hub_consumer_group_siem_logging" {
  value = azurerm_eventhub_consumer_group.siem_logging.name
}

output "event_hub_namespace_fqdn" {
  value = "${azurerm_eventhub_namespace.event_hub_namespace.name}.servicebus.windows.net"
}

output "azure_policy_central_logging_event_hub_authorization_rule" {
  value = azurerm_eventhub_authorization_rule.event_hub_authorization_rule.id
}