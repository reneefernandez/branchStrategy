########################
#####  Variables  ######
#######################
variable "Region"{
  type = "string"
}
variable "Environment"{
  type = "string"
}

variable "Account_Name" {
  type = "string"
}

variable "Tag_ECR_Image" {
  type = "string"
}

variable "Key_Path" {}