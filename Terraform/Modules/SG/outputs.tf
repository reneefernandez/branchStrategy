###############################
#### Outputs SG Resources ####
###############################

# ------ SG ALB ID ------
output "SG_ALB_ID" {
    value = aws_security_group.SG_ALB_appUI_App.id
}
# ------ SG ECS ID ------
output "SG_ECS_Task_ID" {
    value = aws_security_group.SG_ECS_Tasks.id
}
