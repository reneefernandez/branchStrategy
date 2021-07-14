#**********************************
#**** Security Group Resources ****
#**********************************

# ---- Security Group for ALB  ----
resource "aws_security_group" "SG_ALB_appUI_App" {
  name        = "SG_ALB_appUI_${var.Environment}"
  description = "controls access to the ALB"
  vpc_id      = "${var.VPC}"
  tags = {
    Name = "SG_ECS_ALB_${var.Environment}"
    Created_by = "Terraform"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---- Security Group for ECS TASKs  ----
resource "aws_security_group" "SG_ECS_Tasks" {
  name        = "SG_ECS_Task_${var.Environment}"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${var.VPC}"
  tags = {
    Name = "SG_ECS_Task_${var.Environment}"
    Created_by = "Terraform"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.SG_ALB_appUI_App.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
