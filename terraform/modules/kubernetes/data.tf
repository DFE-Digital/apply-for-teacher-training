data "azurerm_resource_group" "backing-service-resource-group" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name = local.backing_services_resource_group_name
}

data "azurerm_subnet" "postgres-subnet" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                 = "postgres-snet"
  virtual_network_name = local.vnet_name
  resource_group_name  = var.cluster.cluster_resource_group_name
}

data "azurerm_private_dns_zone" "postgres-dns" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                = local.postgres_dns_zone
  resource_group_name = var.cluster.cluster_resource_group_name
}
