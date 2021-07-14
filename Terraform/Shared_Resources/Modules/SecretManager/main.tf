#**********************************
#***  Secret Manager Resource *****
#**********************************

resource "aws_secretsmanager_secret" "secret_landingpages" {
  name = "${var.secret_name}"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${var.secret_name}"
    Created_by = "Terraform"
  }
}