########################
#####  Variables  ######
#######################

variable "HostedZoneId" {
  type = string
}

variable "Record_Type" {
  type = string
}

variable "Custom_Domain" {
  type = string
}

# variable "Route_Zone_Domain" {
#   type = string
#   default = "client.com"
# }

variable "Alias_Name" {
  type = string
  default = ""
}

variable "Alias_Hosted_Zone" {
  type = string
  default = ""
}


variable "CName" {
  type = string
  default = ""
}


variable "CName_TTL" {
  type = string
  default = ""
}