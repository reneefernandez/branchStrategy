###############################
#### Outputs SG Resources ####
###############################

# ------ SG ALB ID ------
output "SG_RDS_ID" {
    value = aws_security_group.SG_RDS.id
}

