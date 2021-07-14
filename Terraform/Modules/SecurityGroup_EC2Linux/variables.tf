########################
#####  Variables  ######
#######################

variable "environment" {
    type = string
    description = "The environment name or description"
}

variable "vpc" {
    type = string
    description = "The VPC ID"
}

variable "cidr_vpc" {
    type = string
    description = "CIDR blocks from the vpc that are affected by the security group"
}

variable "sg_name" {
    type = string
    description = "The security group name"

}

variable "sg_description" {
    type = string
    default = "Security group for EC2 instances for InfluxDB"
    description = "Security group for EC2 instances"
}
