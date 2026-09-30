# Creates the Application Load load_balancer

resource "aws_lb" "alb" {
  name               = "tech-challenge-1-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [aws_subnet.public_subnet_1.id,
  aws_subnet.public_subnet_2.id]

  tags = {
    Project = "Tech-Challenge-1"
  }
}


resource "aws_lb_target_group" "alb_tg_front" {
  name        = "alb-targetgroup-frontend"
  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.supernet.id


  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project = "Tech-Challenge-1"
  }

}

resource "aws_lb_target_group" "alb_tg_back" {
  name        = "alb-targetgroup-backend"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.supernet.id


  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project = "Tech-Challenge-1"
  }

}


resource "aws_lb_listener" "alb_listener_frontend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_front.arn
  }

  tags = {
    Project = "Tech-Challenge-1"
  }

}

resource "aws_lb_listener_rule" "lr_backend" {
  listener_arn = aws_lb_listener.alb_listener_frontend.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_back.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
} 