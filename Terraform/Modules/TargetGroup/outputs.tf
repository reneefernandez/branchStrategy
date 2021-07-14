###############################
#### Outputs ALB Resources ####
###############################

# ------ TG ARN  ------
output "TargetGroup_ARN" {
   value = aws_alb_target_group.tgroup.arn
}

output "TargetGroup_Name" {
   value = aws_alb_target_group.tgroup.name
}