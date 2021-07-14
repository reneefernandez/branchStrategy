#**********************************
#**** Security Group Resources ****
#**********************************

# ---- Security Group for ALB  ----
resource "aws_security_group" "SG_ALB" {
  name        = "SG_ECS_ALB_${var.Environment}"
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
    from_port       = "${var.ContainerPort}"
    to_port         = "${var.ContainerPort}"
    security_groups = ["${aws_security_group.SG_ALB.id}"]
  }

  dynamic ingress {
    for_each = "${var.enable_task_def == true ? ["0"] : []}"
    content {
      from_port         = 0
      to_port           = 65535
      protocol          = "tcp"
      cidr_blocks  = ["10.11.0.0/16"]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "example" {
  count             = (var.vpc_cidr != "null" ? 1 : 0)
  type              = "ingress"
  from_port         = "${var.ContainerPort}"
  to_port           = "${var.ContainerPort}"
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.SG_ECS_Tasks.id
}