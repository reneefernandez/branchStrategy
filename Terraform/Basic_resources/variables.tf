variable "Account_Name" {
  type = string
}
variable "Region" {
  type = string
}
variable "Environment" {
  type = list(string)
  default = ["freya", "hela", "vidar"]
}
