resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${terraform.workspace}-${var.K8S_CLUSTER_NAME}-vnet"
  resource_group_name = data.azurerm_resource_group.primary.name
  location            = data.azurerm_resource_group.primary.location
  address_space       = ["10.0.0.0/12"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${terraform.workspace}-${var.K8S_CLUSTER_NAME}-aks_subnet"
  resource_group_name  = data.azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefix       = "10.1.0.0/16"
}

resource "azurerm_subnet" "aks_aci_subnet" {
  name                 = "${terraform.workspace}-${var.K8S_CLUSTER_NAME}-aks_aci_subnet"
  resource_group_name  = data.azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefix       = "10.2.0.0/16"

  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
