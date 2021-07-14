###############################
#### Outputs ALB Resources ####
###############################

output "ALB_DNS" {
   value = aws_alb.ALB.dns_name
}

output "ALB_ARN" {
   value = aws_alb.ALB.arn
}

output "Zone_Id" {
  value = aws_alb.ALB.zone_id
}