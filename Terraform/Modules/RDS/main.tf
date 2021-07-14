#**************************************
#************  IAM Resources **********
#***************************************

provider "aws" {
  alias = "prod-account"
  profile    = "production"
  region     = "us-west-2"
}

# ---- RDS Subnet Group ----
resource "aws_db_subnet_group" "RDS_Subnet_Group" {
  subnet_ids = [var.Subnets[0],var.Subnets[1]]
  tags = {
    Created_by = "Terraform"
  }
}

# ---- RDS instance  ----
resource "aws_db_instance" "RDS_Instance" {
  allocated_storage       = 5
  max_allocated_storage   = 500
  storage_type            = "gp2"
  backup_retention_period = 35
  engine                  = "mysql"
  engine_version          = "5.7.26"
  instance_class          = "${var.Instance_Type}"
  identifier              = "${var.Name}"
  username                = "app"
  backup_window           = "04:46-05:46"
  name                    = "client"
  password                = "${var.PassDB}"
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
  multi_az                = "${var.Multi_AZ}"
  db_subnet_group_name    = "${aws_db_subnet_group.RDS_Subnet_Group.name}"
  vpc_security_group_ids  = ["${var.SecurityGroup}"]
  apply_immediately       = false
  storage_encrypted       = true
  tags = {
    Created_by = "Terraform"
  }
}
