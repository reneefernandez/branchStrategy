###############################
#### Outputs ALB Resources ####
###############################

output "NLB_DNS" {
   value = aws_alb.network_load_balancer.*.dns_name
   #value = aws_alb.network_load_balancer[0].dns_name
}

output "NLB_ARN" {
   value = aws_alb.network_load_balancer.*.arn
}

output "Zone_Id" {
  value = aws_alb.network_load_balancer.*.zone_id
}
