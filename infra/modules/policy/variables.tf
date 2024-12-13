variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "resource_token" {
  description = "A suffix string to centrally mitigate resource name collisions."
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "management_group_name" {
  description = "The name of the management group to assign the policy to."
  type        = string
}

variable "azure_policy_event_hub_authorization_rule_id" {
  description = "The ID of the Event Hub Authorization Rule to use for the policy."
  type        = string
}

variable "central_logging_event_hub_name" {
  description = "The name of the Event Hub to use for central logging."
  type        = string
}