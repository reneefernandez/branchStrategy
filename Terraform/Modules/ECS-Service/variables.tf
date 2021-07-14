## Variables ECS Task

variable "Environment" {
  type = string
}

variable "NumbeOfTask" {
  type = string
}

variable "Region" {
  type = string
}

variable "SecurityGroup" {
  type = string
}

variable "ClusterID" {
  type = string
}

variable "TargetGroup" {
  type = list(string)
}

variable "TaskDefinition" {
  type = string
}

variable "Subnets" {
  type = list(string)
}
variable "ContainerPort" {
  type = string
}
variable "ALB" {
  type    = list(string)
  default = []
}