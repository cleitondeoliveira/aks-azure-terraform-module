resource "azurerm_subnet" "this" {
  name                 = "snet-${var.tags["project"]}-aks-${var.tags["env"]}"
  resource_group_name  = var.subnet["rg"]
  virtual_network_name = var.subnet["vnet"]
  address_prefixes     = [var.subnet["address_prefixes"]]
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = azurerm_subnet.this.id
  nat_gateway_id = data.azurerm_nat_gateway.ng.id
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "id-aks-${var.tags["project"]}-priv-${var.tags["env"]}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azuread_group_member" "this" {
  group_object_id  = data.azuread_group.group.id
  member_object_id = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                                = "aks-${var.tags["project"]}-priv-${var.tags["env"]}"
  location                            = data.azurerm_resource_group.rg.location
  resource_group_name                 = data.azurerm_resource_group.rg.name
  node_resource_group                 = "rg-${var.tags["project"]}-aksresources-${var.tags["env"]}"
  kubernetes_version                  = var.kubernetes_version
  dns_prefix_private_cluster          = "aks-${var.tags["project"]}-priv-${var.tags["env"]}"
  private_dns_zone_id                 = data.azurerm_private_dns_zone.pdns.id
  role_based_access_control_enabled   = true
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = true
 #public_network_access_enabled       = true
  run_command_enabled                 = true
  azure_policy_enabled                = false
  http_application_routing_enabled    = false
  oidc_issuer_enabled                 = false
  open_service_mesh_enabled           = false
  tags                                = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  default_node_pool {
    name                         = "system"
    node_count                   = var.system_node_pool_config.node_count
    vm_size                      = var.system_node_pool_config.vm_size
    only_critical_addons_enabled = var.system_node_pool_config.only_critical_addons_enabled
    type                         = "VirtualMachineScaleSets"
    zones                        = ["1", "2", "3"]
    vnet_subnet_id               = azurerm_subnet.this.id
    max_pods                     = 250
    tags                         = var.tags
  }

  network_profile {
    network_plugin    = "kubenet"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    outbound_type     = "userAssignedNATGateway"
    nat_gateway_profile {
      idle_timeout_in_minutes   = 30
      managed_outbound_ip_count = 1
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  zones                 = ["1", "2", "3"]
  max_pods              = 200
  os_type               = "Linux"
  mode                  = "User"
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.enable_auto_scaling == true ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling == true ? each.value.max_count : null
  node_count            = each.value.enable_auto_scaling == false ? each.value.node_count : null
  node_taints           = each.value.node_taints
  vnet_subnet_id        = azurerm_subnet.this.id
  tags                  = var.tags
  node_labels = {
    "type" = "${each.key}"
  }
}