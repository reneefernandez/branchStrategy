###################
##### Outputs #####
###################

output "KMS_Key" {
   value = aws_kms_key.KMS_client.key_id
}

output "KMS_Key_ARN" {
   value = aws_kms_key.KMS_client.arn
}