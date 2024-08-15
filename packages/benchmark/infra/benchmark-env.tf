

# Random resource group name
resource "random_string" "resource_group_name" {
  count   = var.resource_group_name == null ? 1 : 0
  length  = 8
  special = false
}

locals {
  # Use the provided resource group name or a random one
  resource_group_name = var.resource_group_name == null ? random_string.resource_group_name[0].result : var.resource_group_name
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags
}

# SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Dedicated Host Group & Hosts

resource "azurerm_dedicated_host_group" "main" {
  name                        = "hostgroup-${local.resource_group_name}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  platform_fault_domain_count = 1
  automatic_placement_enabled = false
}

resource "azurerm_dedicated_host" "hosts" {
  name                    = "host-${azurerm_resource_group.main.name}"
  location                = var.location
  dedicated_host_group_id = azurerm_dedicated_host_group.main.id
  sku_name                = var.host_size_family
  platform_fault_domain   = 0
}

# VM

module "test_vm" {
  source = "./modules/benchmark-vm"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dedicated_host_id   = azurerm_dedicated_host.hosts.id
  ssh_public_key      = tls_private_key.ssh_key.public_key_openssh
  vm_size             = var.vm_size

  tags = local.common_tags
}
