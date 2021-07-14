#*************************************
#************ NLB Resources **********
#*************************************


#---------- NLB Creation ----------
resource "aws_alb" "network_load_balancer" {
  count                            = "${var.Enable_NLB == true ? 1 : 0}"
  name                             = "nlb-${var.Environment}"
  internal                         = "${var.Internal}"
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = [var.Subnets[0], var.Subnets[1]]
  tags = {
    Created_by = "Terraform"
  }
}

resource "aws_alb_listener" "listener_https" {
  count             = "${var.Enable_NLB == true ? 1 : 0}"
  load_balancer_arn = "${aws_alb.network_load_balancer[0].id}"
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = "${var.Cert_ARN}"
  default_action {
    target_group_arn = "${var.Target_Group}"
    type             = "forward"
  }
  depends_on = [aws_alb.network_load_balancer[0]]

}

resource "aws_api_gateway_vpc_link" "proxy" {
  count       = "${var.Enable_VPC_link == true ? 1 : 0}"
  name        = "${var.VPC_link_Name}"
  target_arns = [aws_alb.network_load_balancer[0].arn]
  tags = {
    Created_by = "Terraform"
  }
}
