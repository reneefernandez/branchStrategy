output "ARN_Task_Definition" {
   value = (var.EnableVariables == "true"
      ? (length(aws_ecs_task_definition.task_Definition_with_variables) > 0 ? aws_ecs_task_definition.task_Definition_with_variables[0].arn : "")
      : (length(aws_ecs_task_definition.task_Definition_without_variables)> 0 ? aws_ecs_task_definition.task_Definition_without_variables[0].arn : ""))
}
