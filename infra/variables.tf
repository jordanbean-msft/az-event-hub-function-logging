variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "principal_id" {
  description = "The Id of the azd service principal to add to deployed keyvault access policies"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "RG for the deployment"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "storage_account" {
  type = object({
    tier             = string
    replication_type = string
  })
}

variable "event_hub" {
  type = object({
    namespace_sku            = string
    capacity                 = number
    maximum_throughput_units = number
    partition_count          = number
    message_retention        = number
  })
}

variable "function_app" {
  type = object({
    sku_name               = string
    zone_balancing_enabled = bool
    maximum_instance_count = number
    instance_memory_mb     = number
  })
}

variable "management_group_name" {
  description = "The name of the management group to assign the policy to."
  type        = string
}