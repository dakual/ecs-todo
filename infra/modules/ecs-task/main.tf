resource "aws_ecs_task_definition" "main" {
  family                   = "${var.app.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app.task.container_cpu
  memory                   = var.app.task.container_memory
  execution_role_arn       = var.ecs_task_role
  task_role_arn            = var.ecs_task_role
  
  container_definitions = jsonencode([{
    name             = "${var.app.name}"
    image            = "nginx:latest"
    linuxParameters  = {
      initProcessEnabled = true
    }
    essential        = true
    environment      = toset(setunion(var.container_env, var.app.task.container_environment))
    portMappings     = toset(var.app.task.portMappings)
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.ecs_log_group
        awslogs-stream-prefix = var.app.name
        awslogs-region        = var.region
      }
    }
  }])

  tags = {
    Name        = "${var.name}-task-${var.app.name}"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "main" {
  name                               = "${var.app.name}"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.app.service.desired_count
  deployment_minimum_healthy_percent = var.app.service.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.app.service.deployment_maximum_percent
  health_check_grace_period_seconds  = var.app.service.health_check_grace_period_seconds
  enable_execute_command             = true
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = var.ecs_task_sg
    subnets          = var.subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = "${var.app.name}"
    container_port   = var.app.loadbalancer.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.app.autoscaling.max_capacity
  min_capacity       = var.app.autoscaling.min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.app.name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.app.autoscaling.memory.target_value
    scale_in_cooldown  = var.app.autoscaling.memory.scale_in_cooldown
    scale_out_cooldown = var.app.autoscaling.memory.scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.app.name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.app.autoscaling.cpu.target_value
    scale_in_cooldown  = var.app.autoscaling.cpu.scale_in_cooldown
    scale_out_cooldown = var.app.autoscaling.cpu.scale_out_cooldown
  }
}

