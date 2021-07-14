#### Tray IAM Dev ###
resource "aws_iam_user" "iam_user" {
  name = var.Name
  tags = {
    Name = var.Name
    Created_by = "Terraform"
  }
}

resource "aws_iam_access_key" "iam_access" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_policy" {
  name = var.Name
  user = aws_iam_user.iam_user.name

  policy = var.Policy
}

# resource "aws_secretsmanager_secret_version" "tray-production" {
#   secret_id     = "${module.SecretManagerTrayProduction.Secret_ID}"
#   secret_string = jsonencode({"AccessKey" = aws_iam_access_key.tray-production.id, "SecretAccessKey" = aws_iam_access_key.tray-production.secret})
# }