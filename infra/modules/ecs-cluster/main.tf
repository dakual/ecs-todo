resource "aws_ecs_cluster" "main" {
  name = "${var.name}-${var.environment}"
  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.name}"

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
  }
}

output "ecs_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_log_group" {
  value = aws_cloudwatch_log_group.main.name
}