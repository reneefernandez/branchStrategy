##########################################
#### Outputs Secret Manager Resources ####
##########################################

# output "Secret_ARN" {
#     value = aws_secretsmanager_secret.Secret_client.arn 
# }

# output "Secret_ID" {
#     value = aws_secretsmanager_secret.Secret_client.id
# }
output "Secret_ARN" {
   value = (var.kms_Key  != "FALSE"
      ? (length(aws_secretsmanager_secret.Secret_clientKMS) > 0 ? aws_secretsmanager_secret.Secret_clientKMS[0].arn : "")
      : (length(aws_secretsmanager_secret.Secret_client)> 0 ? aws_secretsmanager_secret.Secret_client[0].arn : ""))
}

output "Secret_ID" {
    value = (var.kms_Key  != "FALSE"
      ? (length(aws_secretsmanager_secret.Secret_clientKMS) > 0 ? aws_secretsmanager_secret.Secret_clientKMS[0].id : "")
      : (length(aws_secretsmanager_secret.Secret_client)> 0 ? aws_secretsmanager_secret.Secret_client[0].id : ""))
}