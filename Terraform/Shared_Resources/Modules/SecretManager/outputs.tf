##########################################
#### Outputs Secret Manager Resources ####
##########################################

output "Secret_ARN" {
    value = aws_secretsmanager_secret.secret_landingpages.arn 
}