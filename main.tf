# dns zone
resource "azurerm_private_dns_zone" "zone" {
  name                = var.endpoint.private_dns_zone
  resource_group_name = var.endpoint.resourcegroup
}

# network link
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "link"
  resource_group_name   = var.endpoint.resourcegroup
  private_dns_zone_name = azurerm_private_dns_zone.zone.name
  virtual_network_id    = var.endpoint.virtual_network_id
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
