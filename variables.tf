variable "resource_group" {
  type        = string
  description = "The resource group where the cluster will be created"
}

variable "name" {
  type        = string
  description = "Name of the AKS cluster"

  validation {
    condition     = length(var.name) <= 10
    error_message = "The name of the AKS use case must be equal to or less than 10 characters long."
  }
}

variable "sku_tier" {
  type        = string
  default     = "Free"
  description = "The SKU tier you wish to use, valid values are (Free, Standard). Selecting the Standard SKU will give you the uptime SLA."

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "Valid values for variable: sku_tier are (Free, Standard)."
  }
}

variable "authorized_ip_ranges" {
  type        = list(string)
  description = "Authorized IP ranges for the AKS cluster if AKS cluster is not publicly accessible."
  default     = null

  validation {
    condition = alltrue([
      for a in var.authorized_ip_ranges : can(cidrnetmask(a))
    ])
    error_message = "All elements in variable `authorized_ip_ranges` must be valid IPv4 CIDR block addresses."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable public network access for the AKS cluster"
}

variable "use_managed_identity" {
  type        = bool
  description = "Toggles wether the AKS is built using a managed identity (true) or a Service Principal to authenticate within Azure Cloud (false); Managed Identity is the recommended approach."
  default     = true
}

variable "aks_subnet_id" {
  type        = string
  description = "The subnet ID to use for the AKS cluster"
}

variable "aks_vnet_id" {
  type        = string
  default     = null
  description = "Scope to provide Network Contributor access to the AKS cluster when deploying Ingress NGINX"
}

variable "environment_name" {
  type        = string
  description = "The name of the environment to deploy the AKS cluster in, commonly used names are dev, qa and prod."

  validation {
    condition     = contains(["dev", "staging", "ppe", "qa", "prod", "prd", "all"], var.environment_name)
    error_message = "Valid values for variable: environment_name are (dev, staging, ppe, qa, prod, prd, all)."
  }
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the key vault where you want to store the AKS cluster secrets"
}


variable "aks_configuration" {
  description = "Defines AKS performance and size parameters"
  type = object({
    vm_size                           = string
    os_disk_size_gb                   = number
    kubernetes_node_count             = number
    kubernetes_min_node_count         = number
    kubernetes_max_node_count         = number
    kubernetes_enable_auto_scaling    = bool
    temporary_name_for_rotation       = string
    network_plugin                    = string
    max_pods                          = number
    network_policy                    = string
    kubernetes_version                = string
    kubernetes_default_node_pool_name = string
    load_balancer_sku                 = string
  })
  default = {
    kubernetes_enable_auto_scaling    = false
    kubernetes_max_node_count         = null
    kubernetes_min_node_count         = null
    kubernetes_node_count             = 2
    kubernetes_version                = "1.23.8"
    max_pods                          = 50
    temporary_name_for_rotation       = "tmpaks"
    network_plugin                    = "azure"
    network_policy                    = "azure"
    os_disk_size_gb                   = 128
    vm_size                           = "Standard_D2s_v5"
    kubernetes_default_node_pool_name = "agentpool"
    load_balancer_sku                 = "basic"
  }

  validation {
    condition     = var.aks_configuration.temporary_name_for_rotation != var.aks_configuration.kubernetes_default_node_pool_name
    error_message = "The value `temporary_name_for_rotation` has to be different from the `kubernetes_default_node_pool_name`."
  }
  validation {
    condition     = var.aks_configuration.kubernetes_default_node_pool_name != var.aks_configuration.temporary_name_for_rotation
    error_message = "The value `kubernetes_default_node_pool_name` has to be different from the `temporary_name_for_rotation`."
  }
  validation {
    condition     = var.aks_configuration.temporary_name_for_rotation < 8
    error_message = "value of `temporary_name_for_rotation` must be less than 8 characters."
  }
  validation {
    condition     = var.aks_configuration.kubernetes_default_node_pool_name < 16
    error_message = "value of `temporary_name_for_rotation` must be less than 16 characters."
  }
  validation {
    condition     = contains(["azure", "kubenet", "none"], var.aks_configuration.network_plugin)
    error_message = "Valid values for variable: network_plugin are (azure, kubenet, none)."
  }
  validation {
    condition     = contains(["azure", "calico"], var.aks_configuration.network_policy)
    error_message = "Valid values for variable: network_policy are (azure, calico)."
  }
  validation {
    condition     = contains(["basic", "standard"], var.aks_configuration.load_balancer_sku)
    error_message = "Valid values for variable: load_balancer_sku are (basic, standard)."
  }
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.aks_configuration.kubernetes_version))
    error_message = "The value of `kubernetes_version` must be a valid Kubernetes version."
  }
  validation {
    condition     = var.aks_configuration.os_disk_size_gb > 32
    error_message = "The value of `os_disk_size_gb` must be greater than 32."
  }
}

variable "aks_second_nodepool_configuration" {
  description = "Defines AKS user nodepool performance and size parameters"
  type = object({
    vm_size                        = string
    os_disk_size_gb                = number
    kubernetes_node_count          = number
    kubernetes_min_node_count      = number
    kubernetes_max_node_count      = number
    kubernetes_enable_auto_scaling = bool
    max_pods                       = number
    node_pool_name                 = string
  })
  default = {
    vm_size                        = "Standard_B2s"
    os_disk_size_gb                = 32
    kubernetes_node_count          = 1
    kubernetes_min_node_count      = 1
    kubernetes_max_node_count      = 1
    kubernetes_enable_auto_scaling = true
    max_pods                       = 30
    node_pool_name                 = "workerpool"
  }

  validation {
    condition     = var.aks_second_nodepool_configuration.node_pool_name < 16
    error_message = "value of `temporary_name_for_rotation` must be less than 16 characters."
  }
  validation {
    condition     = var.aks_second_nodepool_configuration.os_disk_size_gb > 32
    error_message = "The value of `os_disk_size_gb` must be greater than 32."
  }

}

variable "aks_second_nodepool" {
  type        = bool
  description = "Toggles wether the AKS is using an additional nodepool. Make sure that load_balancer_sku has to be set to 'standard'"
  default     = false
}

variable "aks_node_authentication" {
  description = "SSH Information to access node pool vms"
  type = object({
    node_admin_username   = string
    node_admin_ssh_public = string
  })
}

variable "aks_addons" {
  description = "Defines which addons will be activated."
  type = object({
    aks_log_analytics_workspace_id   = string
    aks_log_analytics_workspace_name = string
    enable_kubernetes_dashboard      = bool
    enable_azure_policy              = bool
  })
  default = {
    aks_log_analytics_workspace_id   = ""
    aks_log_analytics_workspace_name = ""
    enable_kubernetes_dashboard      = false
    enable_azure_policy              = false
  }
}

variable "ingress_controller" {
  type        = bool
  default     = false
  description = "Set this value to true if you want to use an ingress controller"
}

variable "metrics_enabled" {
  type        = bool
  description = "Allow exposing nginx-ingress metrics for prometheus-operator"
  default     = false
}

variable "argo_cd" {
  type        = bool
  default     = false
  description = "Set this value to true if you want to use Argo CD"
}

variable "ip_domain_name_label" {
  type        = string
  default     = null
  description = "The domain name label for the AKS cluster's public IP address"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,16}$", var.ip_domain_name_label))
    error_message = "The value `ip_domain_name_label` must be no more than 16 characters and only contain lowercase letters, dashes, and numbers"
  }
}
