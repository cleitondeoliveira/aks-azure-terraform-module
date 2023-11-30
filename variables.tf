#improve your varibles 

variable "location" {
  description = "The Azure region into which the cluster should be deployed"
  default     = "East US"
}

variable "ARM_CLIENT_ID" {
  description = "(Required) The Client ID which should be used"
  default     = ""
}

variable "ARM_CLIENT_SECRET" {
  description = "(Required) The Client Secret which should be used"
  default     = ""
}

variable "ARM_TENANT_ID" {
  description = "(Required) The Tenant ID which should be used"
  default     = ""
}

variable "ARM_SUBSCRIPTION_ID" {
  description = "(Required) The Subscription ID which should be used"
  default     = ""
}

variable "private_link_dns_zone" {
  description = "Private DNS zone where AKS privatelink will be created: default = {subscription_id =\"\" name=\"\" resource_group_name=\"\"}"
  default = {
    subscription_id     = ""
    name                = ""
    resource_group_name = ""
  }
}

variable "subnet" {
  description = "Subnet configurations for system template: default = {rg=\"rg-network\" vnet=\"vnetDefault\" address_prefixes=\"172.50.0.0/24\" natgateway_name =\"nat-gateway-prd\"}"
  default = {
    rg               = ""
    vnet             = ""
    address_prefixes = ""
    natgateway_name  = ""
  }
}

variable "kubernetes_version" {
  description = "Version of Kubernetes used for the Agents. If not specified, the default node pool will be created with the version specified by kubernetes_version"
  default     = ""
}

variable "system_node_pool_config" {
  description = "Node count for AKS System NodePool (default=1); Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint"
  type        = map(any)
  default = {
    node_count                   = 1
    vm_size                      = ""
    only_critical_addons_enabled = true
  }
}

variable "user_node_pools" {
  description = "List of objects. VM sizes for AKS: default = {system=\"\" support=\"\" kibana=\"S\" elastic=\"\" logstash=\"\"}. Node count for every AKS nodepool:  default={system_count=1 support_min=1 support_max=1 application_min=1 application_max=1}"
  type = map(
    object({
      enable_auto_scaling = bool
      min_count           = optional(number)
      max_count           = optional(number)
      node_count          = optional(number)
      vm_size             = string
      node_taints         = optional(list(string), null)
    })
  )
  default = {}
}

variable "tags" {
  description = "Tags for all resources"
  default = {
    "terraform"       = true
    "env"             = ""
    "project"         = ""
    "tier"            = ""
    "business_impact" = ""
    "revenue_impact"  = ""
    "region"          = ""
    "business_unit"   = ""
    "vertical"        = ""
  }
}