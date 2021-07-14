#*************************
#*****  ECS Service ******
#*************************

locals {
    tg_groups = (var.TargetGroup[1] == "null" ? [var.TargetGroup[0]] : var.TargetGroup )
}
#---------- ECS Service  ----------
resource "aws_ecs_service" "service-ecs" {
  depends_on      = [var.ALB]
  name            = "Service-${var.Environment}"
  cluster         = var.ClusterID
  task_definition = var.TaskDefinition
  desired_count   = var.NumbeOfTask
  health_check_grace_period_seconds = 5
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [var.SecurityGroup]
    subnets         = [var.Subnets[0],var.Subnets[1]]
  }
  dynamic load_balancer  {
    for_each = local.tg_groups
    content {
      target_group_arn = load_balancer.value
      container_name   = "Container-${var.Environment}"
      container_port   = var.ContainerPort
    }
    }
}