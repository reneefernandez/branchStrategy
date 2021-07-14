#### Tray IAM Dev ###
resource "aws_iam_user" "tray-dev" {
  name = "trayio-dev"
  tags = {
    Name = "trayio-dev"
    Created_by = "Terraform"
  }
}

resource "aws_iam_access_key" "tray-dev" {
  user = aws_iam_user.tray-dev.name
}

resource "aws_iam_user_policy" "tray-dev" {
  name = "trayio-dev"
  user = aws_iam_user.tray-dev.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-west-2:561491151124:secret:Tray-*-test-*",
                "arn:aws:secretsmanager:us-west-2:561491151124:secret:Tray-*-latest-*"
            ]
        }
    ]
}
EOF
}

#### Tray IAM Preview ###
resource "aws_iam_user" "tray-preview" {
  name = "trayio-preview"
  tags = {
    Name = "trayio-preview"
    Created_by = "Terraform"
  }
}

resource "aws_iam_access_key" "tray-preview" {
  user = aws_iam_user.tray-preview.name
}

resource "aws_iam_user_policy" "tray-preview" {
  name = "trayio-preview"
  user = aws_iam_user.tray-preview.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-west-2:561491151124:secret:Tray-*-preview-*"
            ]
        }
    ]
}
EOF
}

#### Tray IAM Production ###
resource "aws_iam_user" "tray-production" {
  name = "trayio-production"
  tags = {
    Name = "trayio-production"
    Created_by = "Terraform"
  }
}

resource "aws_iam_access_key" "tray-production" {
  user = aws_iam_user.tray-production.name
}

resource "aws_iam_user_policy" "tray-production" {
  name = "trayio-production"
  user = aws_iam_user.tray-production.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-west-2:561491151124:secret:Tray-*-production-*"
            ]
        }
    ]
}
EOF
}

# Tray access key to secret
resource "aws_secretsmanager_secret_version" "tray-latest" {
  secret_id     = "${module.SecretManagerTrayLatest.Secret_ID}"
  secret_string = jsonencode({"AccessKey" = aws_iam_access_key.tray-dev.id, "SecretAccessKey" = aws_iam_access_key.tray-dev.secret})
}

resource "aws_secretsmanager_secret_version" "tray-preview" {
  secret_id     = "${module.SecretManagerTrayPreview.Secret_ID}"
  secret_string = jsonencode({"AccessKey" = aws_iam_access_key.tray-preview.id, "SecretAccessKey" = aws_iam_access_key.tray-preview.secret})
}

resource "aws_secretsmanager_secret_version" "tray-production" {
  secret_id     = "${module.SecretManagerTrayProduction.Secret_ID}"
  secret_string = jsonencode({"AccessKey" = aws_iam_access_key.tray-production.id, "SecretAccessKey" = aws_iam_access_key.tray-production.secret})
}