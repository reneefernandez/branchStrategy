variable "Domain" {
  type        = string
  description = "Domain to use for SES"
}

variable "HostedZoneId" {
  type        = string
  description = "Route 53 zone ID for the SES domain verification"
  default     = null
}

variable "SES_records" {
  type        = list(string)
  description = "Additional entries which are added to the _amazonses record"
  default     = []
}

variable "Region"{
    type = "string"
    default = "us-west-2"
}

variable "Account_Name" {
  type = "string"
  default = ""
}
