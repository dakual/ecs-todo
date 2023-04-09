resource "aws_efs_file_system" "main" {
  creation_token = "${var.name}-efs-${var.environment}"

  tags = {
    Name         = "${var.name}-task-${var.environment}"
    Environment  = var.environment
  }
}

resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = 1001
    uid = 1001
  }
  
  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = 0777
    }
  }
}

resource "aws_efs_mount_target" "main" {
  count = length(var.private_subnets)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnets[count.index].id
  security_groups = var.efs_sg
}

output "efs_id" {
  value = aws_efs_file_system.main.id
}

output "efs_ap_id" {
  value = aws_efs_access_point.main.id
}
