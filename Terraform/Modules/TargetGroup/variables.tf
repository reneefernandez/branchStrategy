#######################
#####  Variables  #####
#######################
variable "TG_Name"{
  type = string
}
variable "TG_Port"{
    type = string
}
variable "VPC" {
    type = string
}
variable "Path"{
  type = string
  default = "/"
}
variable "PortHealthChecks" {
  type = string
}
variable "Target_Type"{
  type = string
}
variable "Protocol"{
  type = string
  default = "HTTP"
}