#***************************
#***  Auto Scaling ECS *****
#***************************


#--- auto scaling ecs ---
resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = "${var.max_tasks}"
  min_capacity       = "${var.min_tasks}"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#--- auto scaling policies ---

#--- auto scaling cpu up ---
resource "aws_appautoscaling_policy" "ecs_policy_cpu_up" {
  name               = "asg-scale-up-cpu-${var.Environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_service.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_service.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_service.service_namespace}"
  target_tracking_scaling_policy_configuration {
    target_value       = "${var.CPU_Limit}"
    scale_in_cooldown  = 600
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type  = "ECSServiceAverageCPUUtilization"
    }
  }
}

#--- auto scaling memory up ---

resource "aws_appautoscaling_policy" "ecs_policy_memory_up" {
  name               = "asg-scale-up-memory-${var.service_name}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_service.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_service.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_service.service_namespace}"
  target_tracking_scaling_policy_configuration {
    target_value       = "${var.Memory_Limit}" 
    scale_in_cooldown  = 600
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type  = "ECSServiceAverageMemoryUtilization"
    }
  }
}


### CloudWatch Alarms

# --- High memory alarm  --- 
resource "aws_cloudwatch_metric_alarm" "high-memory-policy-alarm" {
  alarm_name          = "high-memory-ecs-service-${var.Environment}"
  alarm_description   = "High Memory Landing Page for  ecs service for ${var.Environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.Memory_Limit}"
  dimensions = {
    "ServiceName" = "${var.service_name}",
    "ClusterName" = "${var.cluster_name}"
  }
}


# --- High CPU alarm  --- 
resource "aws_cloudwatch_metric_alarm" "high-cpu-policy-alarm" {
  alarm_name          = "high-cpu-ecs-service-${var.Environment}"
  alarm_description   = "High CPUPolicy Landing Page for  ecs service for ${var.Environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.CPU_Limit}"
  dimensions = {
    "ServiceName" = "${var.service_name}",
    "ClusterName" = "${var.cluster_name}"
  }
}