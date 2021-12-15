variable "subscription_id" {
  description = "Azure Subcription ID where the resources are to be configured"
  sensitive   = true
}

variable "client_id" {
  description = "Azure Service Principal AppID for authentication"
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal Password for authentication"
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Service Principal Tenant for authentication"
  sensitive   = true
}

variable "agents_rg" {
  description   = "Resource Group name for the created Virtual Machines"
}
