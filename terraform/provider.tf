terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
  }
}

provider "azurerm" {
    features {}      
    subscription_id = "xxxxx"  
    client_id = "xxxxxx"
    client_secret = "xxxxxx"
    tenant_id = "xxxxxx"
}