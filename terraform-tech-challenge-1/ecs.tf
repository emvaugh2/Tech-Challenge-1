

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "tech-challenge-ecs-cluster-1"

  tags = {
    Project = "Tech-Challenge-1"
  }

}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${aws_ecr_repository.frontend_repo.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cw_lg_front.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }




  }])

  tags = {
    Project = "Tech-Challenge-1"
  }

}

# Family = version history. So think like frontend:1, frontend:2, frontend:3. The family would be the "frontend" part. 

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.frontend_sg.id]
    subnets = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]
    assign_public_ip = false
  }
  desired_count = 1




  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg_front.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.alb_listener_frontend]


  tags = {
    Project = "Tech-Challenge-1"
  }


}




resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cw_lg_back.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }


  }])

  tags = {
    Project = "Tech-Challenge-1"
  }

}

# Family = version history. So think like frontend:1, frontend:2, frontend:3. The family would be the "frontend" part. 

resource "aws_ecs_service" "backend_service" {
  name            = "backend-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.backend_sg.id]
    subnets = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]
    assign_public_ip = false
  }
  desired_count = 1


  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg_back.arn
    container_name   = "backend"
    container_port   = 8080
  }


  tags = {
    Project = "Tech-Challenge-1"
  }


}