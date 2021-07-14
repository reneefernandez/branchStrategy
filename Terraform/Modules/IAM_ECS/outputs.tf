###############################
#### Outputs IAM Resources ####
###############################

# ------ SG ALB ID ------

output "ARN_ECS_Role" {
   value = aws_iam_role.RoleECS.arn
}

