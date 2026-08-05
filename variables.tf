variable "location" {
  description = "Azure Region"
  type        = string
  default     = "(South America) Brazil South"
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rg-novapay-prod"
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
  default     = "vnet-novapay-prod"
}

variable "vnet_address_space" {
  description = "Virtual Network CIDR"
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "web_subnet" {
  description = "Web Subnet CIDR"
  type        = string
  default     = "10.20.10.0/24"
}

variable "app_subnet" {
  description = "Application Subnet CIDR"
  type        = string
  default     = "10.20.20.0/24"
}

variable "db_subnet" {
  description = "Database Subnet CIDR"
  type        = string
  default     = "10.20.30.0/24"
}

variable "admin_ip" {
  description = "Administrator public IP address"
  type        = string
  default     = "172.20.10.2/32"
}

variable "vm_size" {
  description = "Size of the Web Virtual Machine"
  type        = string
  default     = "Standard_D2s_v3"
}