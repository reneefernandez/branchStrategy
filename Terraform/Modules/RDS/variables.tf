########################
#####  Variables  ######
#######################
variable "Name" {
    type = "string"
}

variable "Instance_Type" {
    type = "string"
}

variable "Multi_AZ" {
    default = false
}

variable "Subnets" {
    type = "list"
}

variable "SecurityGroup" {
    type = "string"
}
variable "Environment" {
    type = "string"
}

variable "PassDB" {
    type = "string"
    default = "client12345"
}

variable "Account_Name"{
  type = "string"    
}