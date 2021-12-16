prefix = "qa"
location = "uksouth"

vm_defs = [
  {
    name              = "agent-1"
    size              = "Standard_B2s"
    os_storage_type   = "Standard_LRS"
    os_storage_size   = 30
    data_storage_type = "Standard_LRS"
    data_storage_size = 50
    # Leave blank to accept defaults defined in main.tf
    image_offer = ""
    image_sku = ""
  },
  {
    name              = "agent-2"
    size              = "Standard_B2s"
    os_storage_type   = "Standard_LRS"
    os_storage_size   = 30
    data_storage_type = "Standard_LRS"
    data_storage_size = 50
    image_offer       = "0001-com-ubuntu-server-focal"
    image_sku         = "20_04-lts-gen2"
  }
]
