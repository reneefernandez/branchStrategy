###############################
#### Outputs IAM Resources ####
###############################

# ------ Name Instance Profile ------

output "Role_ARN" {
   value = aws_iam_role.CrossAccountRoleSSA.arn
}

output "Role_Lambda" {
   value = aws_iam_role.RoleECSLambda.arn
}

