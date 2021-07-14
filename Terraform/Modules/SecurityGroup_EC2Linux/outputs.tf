###############################
#### Outputs SG Resources ####
###############################

output "security_group_arn" {
  value = aws_security_group.sg_influxdb.arn
}

output "security_group_id" {
  value = aws_security_group.sg_influxdb.id
}