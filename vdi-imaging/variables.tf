variable "azure_location" {
  description = "Value of the azure location for resources"
  type        = string
  default     = "uksouth"

}

variable "resource_group" {
  description = "Resource group name all resources will be stored inside"
  type        = string
  default     = "sb-rg-imaging-tf"

}

variable "resource_prefix" {
  description = "Value to be prefixed to all resources"
  type        = string
  default     = "sb-"

}

variable "my_ip" {
  description = "My home IP for locking down NSG"
  type        = string
  sensitive = true

}

variable "username" {
  description = "Username for VM's"
  type        = string
  sensitive = true

}

variable "password" {
  description = "Password for VM's"
  type        = string
  sensitive = true

}