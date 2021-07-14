########################
#####  Variables  ######
#######################
variable "Name" {
  type = string
}
variable "ARN_Secrets" {
  type    = list
  default = []
}
variable "Account_ID_SS" {
  type = string
}

variable "Account_ID_Current" {
  type = string
}
variable "Region" {
  type = string
}

variable "EnableSecretManger" {
  type = bool
}

variable "KMS_Key" {
  type    = list
  default = []
}