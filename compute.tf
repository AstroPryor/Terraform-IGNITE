resource "aws_ecs_cluster" "main" {
  name = "astro-cluster"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/astro-app"
  retention_in_days = 7
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "astro-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "astro-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "astro-app"
      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true
      environment = [
        { name = "APP_NAME", value = "astro-app" },
        { name = "ENVIRONMENT", value = "dev" },
        { name = "AWS_REGION", value = "us-west-2" }
      ]
      secrets = [
        { name = "CLIENT_ID", valueFrom = aws_secretsmanager_secret.client_id.arn }
      ]
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "astro-app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "astro-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "astro-app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.app]
}
