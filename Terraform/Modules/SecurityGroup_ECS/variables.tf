########################
#####  Variables  ######
#######################

variable "Environment"{
    type = string
}

variable "VPC"{
    type = string
}

variable "ContainerPort"{
    type = string
}

variable "vpc_cidr"{
    type = string
    default = "null"
}

variable "enable_task_def"{
    type = bool
    default = false
}

