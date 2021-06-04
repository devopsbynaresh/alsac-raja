resource "aws_efs_file_system" "jenkins_backend" {
  creation_token = "jenkins-backend"
  encrypted      = true
  tags           = merge(
    local.common_tags,
    map (
      "Name", "jenkins-backend"
    )
  )
}

resource "aws_efs_access_point" "jenkins_access_point" {
  file_system_id = aws_efs_file_system.jenkins_backend.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/var/jenkins_home"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0755
    }
  }
  tags = merge(
    local.common_tags
  )
}

resource "aws_efs_mount_target" "jenkins_mount_target" {
  file_system_id   = aws_efs_file_system.jenkins_backend.id
  subnet_id        = var.priv_1a_subnet
  security_groups  = [aws_security_group.efs_access_from_jenkins.id]
}

resource "aws_security_group" "efs_access_from_jenkins" {
  name        = "efs_access_from_jenkins"
  description = "Allow inbound traffic from Jenkins"
  vpc_id      = var.vpc_id
  tags        = merge(
    local.common_tags
  )
}

resource "aws_security_group_rule" "efs_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jenkins_access.id
  security_group_id        = aws_security_group.efs_access_from_jenkins.id
}

resource "aws_security_group_rule" "efs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_access_from_jenkins.id
}

resource "aws_efs_file_system_policy" "jenkins_backend_policy" {
  file_system_id = aws_efs_file_system.jenkins_backend.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "jenkins-access-policy",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.jenkins_backend.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}