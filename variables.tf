variable "subscription_id" {
  }
variable "location" {
	default = "uksouth"
}
variable "cluster_name" {
	default = "AKSCluster" 
}
variable "dns_prefix" {
	default = "aks"
  }
variable "admin_user" {
	default = "adminuser"  
}
variable "node_count" {
	default = "1"
}
variable "ssh_public_key" {
	default = "password"
}
variable "linuxuser" {
	default = "linuxadmin"  
}
variable "linuxpassword" {
	}