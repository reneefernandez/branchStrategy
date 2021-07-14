## Variables ECS Task

variable "Environment"{
  type = string
}

variable "CPU" {
    type = string
}

variable "Memory" {
    type = string
}

variable "URL_Repo" {
    type = string
}

variable "RoleECS" {
    type = string
}

variable "Region" {
    type = string
}

variable "TD_Name" {
    type = string
}

variable "ContainerPort" {
    type = string
}

variable "EnableVariables" {
    type = string
}

variable "ARN_Secrets" {
    type = "list"
    default = []
}