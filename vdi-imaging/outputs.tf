# Print Public IP in Shell
output "public_ip" {
  value = azurerm_public_ip.dc_public_ip.ip_address
}