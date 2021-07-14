##Network Settings for client Environments

variable "Region"{
    type = "string"
}
variable "Environment"{
  type = "string"    
}

variable "Account_Name"{
  type = "string"    
}

variable "CIDR_Blocks_Latest" {
    type = "list"
    default = ["10.12.0.0/16"]
}

variable "CIDR_Blocks_Production" {
    type = "list"
    default = ["10.13.0.0/16"]
}

variable "CIDR_Blocks_Dev" {
    type = "list"
    default = ["10.150.0.0/16"]
}