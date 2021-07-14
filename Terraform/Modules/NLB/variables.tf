########################
#####  Variables  ######
#######################

variable "Environment" {
  type = "string"
}

variable "Subnets" {
  type = "list"
}

variable "Cert_ARN" {
  type = "string"
}

variable "Internal" {
  default = false
}

variable "Random_Id" {
  type = "string"
}

variable "Target_Group" {
  type = "string"
}

variable "Account_Name" {
  type = "string"
}

variable "Enable_NLB" {
  type = bool
}

variable "Enable_VPC_link" {
  type = bool
}

variable "VPC_link_Name" {
  type = "string"
}