#***********************************
#******** ECS Task Definition ******
#***********************************

locals {
    secrets_json =  jsonencode(var.ARN_Secrets)
}

#---------- ECS Task Definition without ENV variables ----------
resource "aws_ecs_task_definition" "task_Definition_without_variables" {
  count                    = var.EnableVariables == "false" ? 1 : 0
  family                   = "TaskDF-${var.TD_Name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.CPU
  memory                   = var.Memory
  execution_role_arn       = var.RoleECS
  tags = {
    Created_by = "Terraform"
  }
  container_definitions = <<DEFINITION
            [
              {
                "logConfiguration": {
                    "logDriver": "awslogs",
                    "secretOptions": null,
                    "options": {
                      "awslogs-group": "/ecs/TaskDF-${var.TD_Name}",
                      "awslogs-region": "${var.Region}",
                      "awslogs-stream-prefix": "ecs"
                    }
                  },
                "cpu": 0,
                "image": "${var.URL_Repo}",
                "name": "Container-${var.Environment}",
                "networkMode": "awsvpc",
                "portMappings": [
                  {
                    "containerPort": ${var.ContainerPort},
                    "hostPort": ${var.ContainerPort}
                  }
                ]
              }
            ]
            DEFINITION
}

#---------- ECS Task Definition with ENV variables ----------
resource "aws_ecs_task_definition" "task_Definition_with_variables" {
  count                    = var.EnableVariables == "true" ? 1 : 0
  family                   = "TaskDF-${var.TD_Name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.CPU
  memory                   = var.Memory
  execution_role_arn       = var.RoleECS
  container_definitions    = <<DEFINITION
            [
              {
                "logConfiguration": {
                    "logDriver": "awslogs",
                    "secretOptions": null,
                    "options": {
                      "awslogs-group": "/ecs/TaskDF-${var.TD_Name}",
                      "awslogs-region": "${var.Region}",
                      "awslogs-stream-prefix": "ecs"
                    }
                  },
                "cpu": 0,
                "image": "${var.URL_Repo}",
                "name": "Container-${var.Environment}",
                "networkMode": "awsvpc",
                "portMappings": [
                  {
                    "containerPort": ${var.ContainerPort},
                    "hostPort": ${var.ContainerPort}
                  }
                ],
                "secrets": ${local.secrets_json}
              }
            ]
            DEFINITION
}


#---------- Cloudwatch Log_group  ----------
resource "aws_cloudwatch_log_group" "TaskDF-Log_Group" {
  name              = "/ecs/TaskDF-${var.TD_Name}"
  retention_in_days = 7
}

