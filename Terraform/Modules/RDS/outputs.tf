output "RDS_EndPoint" {
   value = aws_db_instance.RDS_Instance.address
}

output "RDS_ZoneId" {
   value = aws_db_instance.RDS_Instance.hosted_zone_id
}