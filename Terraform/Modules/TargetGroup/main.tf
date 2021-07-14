#*****************************
#******** Target Groups ******
#*****************************

#---------- Target Group ----------

resource "aws_alb_target_group" "tgroup" {
  name                 = "TG-${var.TG_Name}"
  port                 = "${var.TG_Port}"
  protocol             = "${var.Protocol}"
  vpc_id               = "${var.VPC}"
  target_type          = "${var.Target_Type}"
  deregistration_delay = 5
  health_check {
    enabled             = true
    interval            = (var.Protocol == "TCP" ? 30 : 5)
    path                = (var.Protocol == "TCP" ? null : var.Path)
    port                = "${var.PortHealthChecks}"
    protocol            = "${var.Protocol}"
    timeout             = (var.Protocol == "TCP" ? null : 3)
    healthy_threshold   = (var.Protocol == "TCP" ? 3 : 2)
    unhealthy_threshold = 3
    matcher             = (var.Protocol == "TCP" ? null : "200,302")
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Created_by = "Terraform"
  }
}
