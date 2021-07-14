output "replication_role_arn" {
    value       = "${aws_iam_role.s3_replication_role.arn}"
    description = "IAM role arn for S3 replication"
    sensitive   = true 
}