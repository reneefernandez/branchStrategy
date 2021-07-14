#****************************
#******** Managed keys ******
#****************************

resource "aws_kms_key" "KMS_client" {
  description             = var.Key_Name
  deletion_window_in_days = 15
  policy                  = var.Policy

  tags = {
    Created_by = "Terraform"
  }
}

resource "aws_kms_alias" "Alias_KMS" {
  name          = var.Alias_Name
  target_key_id = aws_kms_key.KMS_client.key_id
  depends_on    = [aws_kms_key.KMS_client]
}
