resource "aws_ecs_cluster" "the_cool_ai_cluster" {
  name = "the-cool-ai-cluster"

  tags = {
    Name = "TheCoolAICluster"
  }
}

resource "aws_ecs_task_definition" "the_cool_ai_task" {
  family                   = "the-cool-ai-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "the-cool-ai-container"
      image     = "${aws_ecr_repository.ecr.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "BENTOML_PORT"
          value = "3000"
        }
      ]
    }
  ])

  tags = {
    Name = "TheCoolAITaskDef"
  }
}

resource "aws_ecs_service" "the_cool_ai_service" {
  name            = "the-cool-ai-service"
  cluster         = aws_ecs_cluster.the_cool_ai_cluster.id
  task_definition = aws_ecs_task_definition.the_cool_ai_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.the_cool_ai_tg.arn
    container_name   = "the-cool-ai-container"
    container_port   = 3000
  }

  tags = {
    Name = "TheCoolAIService"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "the-cool-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ECSTaskExecutionRole"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
