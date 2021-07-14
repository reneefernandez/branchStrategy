###############################
#### Outputs IAM Resources ####
###############################

# ------ SG ALB ID ------

# output "aws_iam_user" {
#    value = aws_iam_role.aws_iam_user.arn
# 
output "AccessKey" {
   value = aws_iam_access_key.iam_access.id
}

output "SecretAccessKey" {
   value = aws_iam_access_key.iam_access.secret
}
