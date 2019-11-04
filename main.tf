provider "azurerm" {
  version = "~> 1.36"
}


data "azurerm_resource_group" "primary" {
  name = "Team-Sharing-Group"
}

resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name                = "${terraform.workspace}-${var.K8S_CLUSTER_NAME}-k8s-cluster"
  location            = data.azurerm_resource_group.primary.location
  resource_group_name = data.azurerm_resource_group.primary.name
  dns_prefix          = "${terraform.workspace}-${var.K8S_CLUSTER_NAME}"
  kubernetes_version  = "1.14.7"

  agent_pool_profile {
    name                = "low"
    count               = 1
    max_count           = 2
    min_count           = 1
    os_disk_size_gb     = 100
    os_type             = "Linux"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  }

  agent_pool_profile {
    name                = "standard"
    count               = 1
    max_count           = 5
    max_pods            = 110
    min_count           = 1
    os_disk_size_gb     = 100
    os_type             = "Linux"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    vm_size             = "Standard_A2m_v2"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.0.0.10"
    service_cidr       = "10.0.0.0/16"
    load_balancer_sku  = "Standard"
  }
  addon_profile {
    aci_connector_linux {
      enabled     = true
      subnet_name = azurerm_subnet.aks_aci_subnet.name
    }
  }

  service_principal {
    client_id     = var.K8S_CLIENT_ID
    client_secret = var.K8S_CLIENT_SECRET
  }

  tags = {
    Environment = terraform.workspace
  }
}

output "kube_config_notice" {
  value = "Plz run to fetch kubeconfig to local:\n az aks get-credentials --name ${azurerm_kubernetes_cluster.k8s_cluster.name} --resource-group ${data.azurerm_resource_group.primary.name}"
}
