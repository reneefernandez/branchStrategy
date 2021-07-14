########################
#####  Variables  ######
#######################
variable "regionaws"{
    default = "us-west-2"
}

variable "Name_VPC" {
    type = "string"
    default = "VPC_client_Latest"
}
variable "Environment" {
    type = "string"
}
variable "CIDR" {
    type = "list"
}

variable "Subnets_Number" {
  default = 2
}

variable "Account_Name"{
  type = "string"    
}

variable "TransitGateway"{
  type = "string"    
}