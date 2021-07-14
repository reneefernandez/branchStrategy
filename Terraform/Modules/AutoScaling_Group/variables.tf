########################
#####  Variables  ######
#######################
variable "AMI"{
  type = "string"
}
variable "Environment"{
  type = "string"
}
variable "Instace_type"{
  type = "string"
}
variable "KeyPair"{
  type = "string"
}
variable "AvailabilyZone"{
  type = "list"
}
variable "SecurityGroup"{
  type = "list"
}
variable "Subnets"{
  type = "list"
}