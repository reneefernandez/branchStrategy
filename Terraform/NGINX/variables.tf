########################
#####  Variables  ######
#######################

variable "Account_Name" {
  type = string
}
variable "Region" {
  type = string
}
variable "Environment" {
  type = string
}

variable "Tag_ECR_Image" {
  type    = string
  default = "latest"
}

variable "on_demand" {
  type    = bool
  default = false
}



####################
#####  static ######
####################

variable "Mapping_ECR_Repos" {
  type = map(string)
  default = {
    "nginx"  = "561491151124.dkr.ecr.us-west-2.amazonaws.com/lp_nginx"
    "appd" = "561491151124.dkr.ecr.us-west-2.amazonaws.com/lp_appd"
    "appjs" = "561491151124.dkr.ecr.us-west-2.amazonaws.com/appjs"
  }
}

variable "Mapping_Certs" {
  type = map(string)
  default = {
    "latest"         = "*.staging.client.com"
    "production"     = "*.rollback.client.com"
    "on_demand"      = "*.demo.client.com"
    "on_demand_prod" = "*.hotfix.client.com"
  }
}
