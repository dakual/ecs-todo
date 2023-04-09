resource "aws_db_instance" "main" {
  identifier           = "${var.name}-${var.environment}"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.name
  username             = "admin"
  password             = random_password.rds.result
  parameter_group_name = aws_db_parameter_group.main.name
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.rds_security_groups 
  publicly_accessible  = true
  skip_final_snapshot  = true
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.name}-${var.environment}"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-${var.environment}"
  subnet_ids = var.rds_subnets.*.id

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
  }
}

resource "random_password" "rds" {
  length  = 16
  special = false
}

output "mysql" {
  value = {
    DB_HOST = aws_db_instance.main.address
    DB_NAME = aws_db_instance.main.db_name
    BD_PORT = aws_db_instance.main.port
    DB_USER = aws_db_instance.main.username
    DB_PASS = random_password.rds.result
  }
}
