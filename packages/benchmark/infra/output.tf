output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_name" {
  value = module.test_vm.name
}

output "vm_public_ip" {
  value = module.test_vm.ip
}

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
