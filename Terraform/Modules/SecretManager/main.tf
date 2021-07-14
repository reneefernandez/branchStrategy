#**********************************
#***  Secret Manager Resource *****
#**********************************

resource "aws_secretsmanager_secret" "Secret_client" {
  count = var.kms_Key == "FALSE" ? 1 : 0
  name = var.secret_name
  recovery_window_in_days = var.retention_time
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.secret_name
    Created_by = "Terraform"
  }
}

resource "aws_secretsmanager_secret" "Secret_clientKMS" {
  count = var.kms_Key != "FALSE" ? 1 : 0
  name = var.secret_name
  recovery_window_in_days = var.retention_time
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.secret_name
    Created_by = "Terraform"
  }
  kms_key_id = var.kms_Key
}