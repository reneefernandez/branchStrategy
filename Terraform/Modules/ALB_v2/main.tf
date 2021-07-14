#*************************************
#************ ALB Resources **********
#*************************************


#---------- ALB Creation ----------

resource "aws_alb" "ALB" {
  name               = "ALB-${var.Environment}-${var.Random_Id}"
  subnets            = [ var.Subnets[0],var.Subnets[1] ]
  security_groups    = [var.SecurityGroup]
  load_balancer_type = "application"
  internal           = var.Internal
  enable_http2       = true
  idle_timeout       = var.idleTimeout
  access_logs {
                bucket  = "alb-logs-client"
                prefix  = var.Environment
                enabled = var.Enable_Logs
              }
  tags = {
    Created_by = "Terraform"
  }
}

#---------- Listener HTTP ----------

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.ALB.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [aws_alb.ALB]

}

#---------- Listener HTTPS ----------

resource "aws_alb_listener" "listener_https" {
  load_balancer_arn = aws_alb.ALB.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.Cert_ARN
  default_action {
    target_group_arn = var.Target_Group
    type             = "forward"
  }
  depends_on = [aws_alb.ALB]

}

#################  Rules for HTTP Listener ##########


# ------  Redirects Rules  -----#

resource "aws_lb_listener_rule" "redirect_rules" {
  count = (var.AddRule == "true" ? length(var.ALB_Rules_Redirects) : 0)
  listener_arn = aws_alb_listener.listener_https.arn
  priority     = count.index + 1
  action {
    type = "redirect"
    redirect {
      host        = var.ALB_Rules_Redirects[count.index].Destination_Host
      port        = "443"
      path        = var.ALB_Rules_Redirects[count.index].Path_Destination
      protocol    = "HTTPS"
      query       = var.ALB_Rules_Redirects[count.index].Query_destination
      status_code = "HTTP_301"
    }
  }
  condition {
    path_pattern {
      values = [var.ALB_Rules_Redirects[count.index].Path_Origin]
    }
  }
  condition {
    host_header {
     values = [var.ALB_Rules_Redirects[count.index].Origin_Host]
    }
  }
}
# ------  Deny Show Nginx_Status  -----#

resource "aws_lb_listener_rule" "deny_nginx_status_http" {
  count = var.AddRule == "true" ? 1 : 0
  listener_arn = aws_alb_listener.listener_https.arn
  priority     = 100
  action {
    type = "fixed-response"
    fixed_response {
        content_type  = "text/plain"
        message_body = "401 Unauthorized"
        status_code  = "401"
    }
  }
  condition {
    path_pattern {
      values = ["/nginx_status"]
    }
  }
}