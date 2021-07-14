#************************
#***  S3  Resources *****
#***********************

#---------- Bucket Creation ----------

resource "aws_s3_bucket" "destination_bucket" {
  count  = "${var.Enable_Replication == true ? 0 : 1}"
  bucket = "${var.Bucket_Name}"
  acl    = "private"
  policy = "${var.Policy}"
  
  lifecycle_rule {
    id      = "transition_glacier"
    enabled = true

    transition {
      days = 360
      storage_class = "GLACIER"
    }

  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.KMS_replication}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = {
    Created_by = "Terraform"
  }
}

resource "aws_s3_bucket" "bucket" {
  count  = "${var.Enable_Replication == true ? 1 : 0}"
  bucket = "${var.Bucket_Name}"
  acl    = "private"
  policy = "${var.Policy}"

  lifecycle_rule {
    id      = "transition_glacier"
    enabled = true

    transition {
      days = 360
      storage_class = "GLACIER"
    }

  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.KMS_origin}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  replication_configuration {
    role = "${var.Replication_role}"

    rules {
      prefix = ""
      status = "Enabled"

      source_selection_criteria {
        sse_kms_encrypted_objects {
          enabled = "true"
        }
      }

      destination {
        bucket             = "${var.Replication_Destination_bucket}"
        storage_class      = "STANDARD"
        replica_kms_key_id = "${var.KMS_replication_ARN}"
      }

    }
  }

  tags = {
    Created_by = "Terraform"
  }
}