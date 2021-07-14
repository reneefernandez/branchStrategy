########################
#####  Variables  ######
#######################
variable "secret_name"{
    type = string
}
variable "retention_time" {
    type = number
    }

variable "kms_Key" {
    type = string
    default = "FALSE"
}

