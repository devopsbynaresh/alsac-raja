resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins_cluster"
  tags = merge(
    local.common_tags
  )
}

resource "aws_ecs_service" "jenkins_service" {
  name            = "jenkins_service"
  cluster         = aws_ecs_cluster.jenkins_cluster.id
  task_definition = aws_ecs_task_definition.jenkins_task_def.arn
  desired_count   = 1
  network_configuration {
    subnets         = [var.priv_1a_subnet]
    security_groups = [aws_security_group.jenkins_access.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
    container_name   = "jenkins"
    container_port   = 8080
  }
  launch_type      = "FARGATE"
  ### Platform Version https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html ###
  platform_version = "1.4.0"
  tags             = merge(
    local.common_tags
  )
  depends_on       = [aws_lb.jenkins_lb]
}

resource "aws_ecs_task_definition" "jenkins_task_def" {
  family                   = "jenkins"
  container_definitions    = file("./service.json")
  task_role_arn            = var.jenkins_role
  execution_role_arn       = var.jenkins_role
  network_mode             = "awsvpc"
  volume {
    name                   = "efs_backend"
    efs_volume_configuration {
      file_system_id       = aws_efs_file_system.jenkins_backend.id
      transit_encryption   = "ENABLED"
      authorization_config {
        access_point_id    = aws_efs_access_point.jenkins_access_point.id
        iam                = "ENABLED"
      }
    }
  }
  cpu                      = 1024
  memory                   = 4096
  tags                     = merge(
    local.common_tags
  )
}
