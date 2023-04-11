# Create Private Endpint
resource "azurerm_private_endpoint" "endpoint" {
  name                = "kopicloudnortheurope_pe"
  resource_group_name = azurerm_resource_group.network-rg.name
  location            = azurerm_resource_group.network-rg.location
  subnet_id           = azurerm_subnet.endpoint-subnet.id
  private_service_connection {
    name                           = "kopicloudnortheurope_psc"
    private_connection_resource_id = azurerm_storage_account.asa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

#not sure if required or not
# Create DNS A Record
resource "azurerm_private_dns_a_record" "dns_a" {
  name                = "kopicloudnortheurope"
  zone_name           = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.network-rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}

xxxxxxxxxxxxxx
#we have three options:
#Allow traffic from public networks
#Use a white list to filter public access
#Disable traffic from public networks
#See these three different implementations below.

#1.To allow traffic from Public Networks, add the following code:
# Create Azure Storage Account Network Rules
resource "azurerm_storage_account_network_rules" "rules" {
  storage_account_id = azurerm_storage_account.asa.id
  default_action = "Allow"
  bypass         = ["Metrics", "Logging", "AzureServices"]
}

#2.To use a white list of public IP addresses, add the following code:
# Create a white list of IP Addresses
variable "white_list_ip" {
  type = list(string)
  description = "List of white list of IP Addresses"
}
# Create Azure Storage Account Network Rules
resource "azurerm_storage_account_network_rules" "rules" {
  storage_account_id = azurerm_storage_account.asa.id
  default_action = "Deny"
  ip_rules       = var.white_list_ip
  bypass         = ["Metrics", "Logging", "AzureServices"]
}

#3.To deny traffic from all Public Networks, add the following code:
# Create Azure Storage Account Network Rules
resource "azurerm_storage_account_network_rules" "rules" {
  storage_account_id = azurerm_storage_account.asa.id
  default_action     = "Deny"
  bypass             = ["Metrics", "Logging", "AzureServices"]
}
