variable "subscription_id" {
  description = "Azure Subcription ID where the resources are to be configured"
  sensitive   = true
}

## Enable below variables if a Service Principal is used
# variable "client_id" {
#   description = "Azure Service Principal AppID for authentication"
#   sensitive   = true
# }

# variable "client_secret" {
#   description = "Azure Service Principal Password for authentication"
#   sensitive   = true
# }

# variable "tenant_id" {
#   description = "Azure Service Principal Tenant for authentication"
#   sensitive   = true
# }

variable "prefix" {
  description = "The prefix which should be used for all resources"
}

variable "location" {
  description = "The Azure Region in which all resources should be created."
}

variable "vm_user" {
  description = "The user to be created on any defined the virtual machines"
  default = "adminuser"
}

variable "vm_defs" {
  type        = list(object({
    name              = string
    size              = string
    os_storage_type   = string
    os_storage_size   = number
    data_storage_type = string
    data_storage_size = number
    image_offer       = string
    image_sku         = string
  }))
  description = <<-EOS
    List of Virtual Machine definitions to be created.

    Image Offer/SKU values can be retrieved using:
      az vm image list -p Canonical -f Ubuntu -l <region> --all --output table"

    Image Size/Profile values can be retrieved using:
      az vm list-sizes -l <region> --output table
  EOS
}
