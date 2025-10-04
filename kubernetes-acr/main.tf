terraform {
  backend "azurerm" {
    resource_group_name   = "tf-state-rgp"
    storage_account_name  = "tfstate24019182"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.47.0"
    }
  }
}

provider "azurerm" {
    features {    
    }
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
 
}


resource "azurerm_resource_group" "app67" {
  name     = "app67-resources"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr67" {
  name                = "containerRegistry67"
  resource_group_name = azurerm_resource_group.app67.name
  location            = azurerm_resource_group.app67.location
  sku                 = "Premium"
  admin_enabled       = true
  depends_on = [ azurerm_resource_group.app67 ]
}

resource "azurerm_kubernetes_cluster" "aks67" {
  name                = "example-aks67"
  location            = azurerm_resource_group.app67.location
  resource_group_name = azurerm_resource_group.app67.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
  depends_on = [ azurerm_resource_group.app67 , azurerm_container_registry.acr67]
  
}

resource "azurerm_role_assignment" "kubeide67" {
  principal_id                     = azurerm_kubernetes_cluster.aks67.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr67.id
  skip_service_principal_aad_check = true
  depends_on = [ azurerm_kubernetes_cluster.aks67,azurerm_container_registry.acr67 ]
}
