########################
#####  Variables  ######
#######################
variable "max_tasks" {
  type = number
  default = 1
}
variable "min_tasks" {
  type = number
  default = 1 
}
variable "cluster_name" {
  type = string
}
variable "Environment" {
  type = string
}
variable "service_name" {
  type = string
}
variable "Memory_Limit" {
  type = number
  default = 50
}
variable "CPU_Limit" {
  type = number
  default = 50
}




