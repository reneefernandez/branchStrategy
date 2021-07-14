output "bucket_arn" {
    value       = "${var.Enable_Replication == true ? aws_s3_bucket.bucket[0].arn : aws_s3_bucket.destination_bucket[0].arn}"
    description = "AWS S3 bucket ARN"
    sensitive   = true 
}
