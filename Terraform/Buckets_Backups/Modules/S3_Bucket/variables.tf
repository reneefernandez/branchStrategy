########################
#####  Variables  ######
########################

variable "Bucket_Name" {
  type = "string"
}

variable "Policy" {
  type = "string"
}

variable "Enable_Replication" {
  type = bool
}

variable "Replication_Destination_bucket" {
  type        = "string"
  description = "S3 destination bucket for replication, set to empty when destination bucket is being created"
  default     = ""
}

variable "Replication_role" {
  type        = "string"
  description = "IAM role for replication, set to empty when destination bucket is being created"
  default     = ""
}

variable "KMS_origin" {
  type     = "string"
  description = "Origin KMS key, set to empty when destination bucket is being created"
  default  = ""
}

variable "KMS_replication" {
  type     = "string"
  description = "Replication KMS key, set to empty when origin bucket is being created"
  default  = ""
}

variable "KMS_replication_ARN" {
  type     = "string"
  description = "Replication KMS key ARN, set to empty when destination bucket is being created"
  default  = ""
}