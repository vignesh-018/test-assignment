
variable "rgname"{
    type = string
    description = "used for naming resource group"
}

variable "location"{
    type = string
    description = "used for selecting location"
    default = "eastus"
}

variable "vnetname" {
    type = string 
}

variable "vnet_address_space" {
    type = list(string ) 
}

variable "subnetname" {
    type = string 
}

variable "subnet_address_prifixes" {
    type = list(string)
}

variable "nicname" {
    type = string
 
}

variable "nsgname" {
    type = string
}

variable "admin_username" {
    type = string

}

variable "admin_password" {
  type = string

}

variable "vmname" {
  type = string

}