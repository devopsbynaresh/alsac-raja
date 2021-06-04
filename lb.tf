resource "aws_lb" "jenkins_lb" {
  name               = "jenkins-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_access.id]
  subnets            = [var.priv_1a_subnet, var.priv_lb_subnet]
  tags               = merge(
    local.common_tags
  )
}

resource "aws_lb_target_group" "jenkins_target_group" {
  name        = "jenkins-lb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    interval            = 30
    path                = "/login"
    timeout             = 10
    unhealthy_threshold = 5
    matcher             = "200-209"
  }
  tags = merge(
    local.common_tags
  )
}

resource "aws_lb_listener" "jenkins_front_end" {
  load_balancer_arn = aws_lb.jenkins_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  }
}

resource "aws_security_group" "jenkins_access" {
  name        = "jenkins_access"
  description = "Allow inbound traffic to Jenkins"
  vpc_id      = var.vpc_id
  tags        = merge(
    local.common_tags
  )
}

resource "aws_security_group_rule" "jenkins_access_ingress1" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs_access_from_jenkins.id
  security_group_id        = aws_security_group.jenkins_access.id
}

resource "aws_security_group_rule" "jenkins_access_ingress2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["172.16.0.0/12"]
  security_group_id = aws_security_group.jenkins_access.id
}

resource "aws_security_group_rule" "jenkins_access_ingress3" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["172.16.0.0/12"]
  security_group_id = aws_security_group.jenkins_access.id
}

resource "aws_security_group_rule" "jenkins_access_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_access.id
}