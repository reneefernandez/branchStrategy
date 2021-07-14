########################
#####  Variables  ######
#######################
#### Existing keypair ###########
variable "PublicKeySS" {
  type = "string"
  default = "SSKey_client"
}
variable "Account_Name"{
  type = "string"    
}
variable "Region" {
  type = "string"
}
###### Using Amazon Linux 2 AMI #################
variable "ami" {
  type = "string"
  default = "ami-0873b46c45c11058d"
}
variable "Name"{
  type = "string"
}
variable "vpc"{
  type = "string"
}
variable "Subnets"{
  type = "list"
}
variable "Security_groups"{
  type = "list"
}
variable "Instace_type" {
  type = "string"
}
variable "iam_instance_profile" {
  type = "string"
  default = null
}