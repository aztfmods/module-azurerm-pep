# dns zone
resource "azurerm_private_dns_zone" "zone" {
  name                = var.endpoint.private_dns_zone.name
  resource_group_name = var.endpoint.resourcegroup
}

# generate random id
resource "random_string" "random" {
  length    = 3
  min_lower = 3
  special   = false
  numeric   = false
  upper     = false
}

# network link
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "link${random_string.random.result}"
  resource_group_name   = var.endpoint.resourcegroup
  private_dns_zone_name = azurerm_private_dns_zone.zone.name
  virtual_network_id    = var.endpoint.private_dns_zone.network_link
  registration_enabled  = true
}

# private endpoint
resource "azurerm_private_endpoint" "endpoint" {
  name                = "pep-${var.company}-${var.env}-${var.region}"
  location            = var.endpoint.location
  resource_group_name = var.endpoint.resourcegroup
  subnet_id           = var.endpoint.subnet_id

  private_service_connection {
    name                           = "endpoint"
    is_manual_connection           = false
    private_connection_resource_id = var.endpoint.resource_id
    subresource_names              = var.endpoint.subresources
  }
}

# private dns a record
resource "azurerm_private_dns_a_record" "a_record" {
  name                = var.endpoint.private_dns_zone.a_record.name
  zone_name           = azurerm_private_dns_zone.zone.name
  resource_group_name = var.endpoint.resourcegroup
  ttl                 = try(var.endpoint.private_dns_zone.a_record.ttl, 300)
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}





