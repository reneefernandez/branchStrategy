#**********************************
#**** Security Group Resources ****
#**********************************
# ---- Security Group for RDS instances  ----
resource "aws_security_group" "SG_RDS" {
  description = "controls access to the RDS"
  vpc_id      = "${var.VPC}"
  tags = {
    Name = "SG_RDS_${var.Environment}"
    Created_by = "Terraform"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["${var.CIDR_VPC}","10.11.0.0/16"]
  }
  

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
