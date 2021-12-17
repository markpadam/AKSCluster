#Terrform AKS Deployment

-Log in with "az login"
-Switch context with "az account set --subscription xxxxx"

##Run 
-Terraform Init
-Terraform Plan
-terraform apply

##Terrafom Registry for AKS
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster

##Example terraform.tfvars file
```
location = "uksouth"
subscription_id = "xxxxxxx"
cluster_name = "OneTrust"
admin_user = "onetrustadmin"
node_count = "3"
linuxpassword = "xxxxx"
```