# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = var.cluster_name
  }
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.cluster_name}/api-service"
  retention_in_days = 7

  tags = {
    Name = "${var.cluster_name}-api-logs"
  }
}

resource "aws_cloudwatch_log_group" "auth" {
  name              = "/ecs/${var.cluster_name}/auth-service"
  retention_in_days = 7

  tags = {
    Name = "${var.cluster_name}-auth-logs"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.cluster_name}/frontend"
  retention_in_days = 7

  tags = {
    Name = "${var.cluster_name}-frontend-logs"
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-ecs-task-execution-role"

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
    Name = "${var.cluster_name}-ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-ecs-task-role"

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
    Name = "${var.cluster_name}-ecs-task-role"
  }
}

# API Service Task Definition
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.cluster_name}-api-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "api-service"
      image = "${var.ecr_repository_url}/api-service:${var.image_tag}"
      
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = "3000"
        },
        {
          name  = "DATABASE_URL"
          value = var.database_url
        },
        {
          name  = "AUTH_SERVICE_URL"
          value = "http://auth-service:3001"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.api.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.cluster_name}-api-task"
  }
}

# Auth Service Task Definition
resource "aws_ecs_task_definition" "auth" {
  family                   = "${var.cluster_name}-auth-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "auth-service"
      image = "${var.ecr_repository_url}/auth-service:${var.image_tag}"
      
      portMappings = [
        {
          containerPort = 3001
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = "3001"
        },
        {
          name  = "DATABASE_URL"
          value = var.database_url
        },
        {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.auth.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3001/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.cluster_name}-auth-task"
  }
}

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.cluster_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "${var.ecr_repository_url}/frontend:${var.image_tag}"
      
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.cluster_name}-frontend-task"
  }
}

# ECS Services
resource "aws_ecs_service" "api" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight           = 100
  }

  network_configuration {
    security_groups  = [var.security_group_id]
    subnets         = var.subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.api_target_group_arn
    container_name   = "api-service"
    container_port   = 3000
  }

  depends_on = [var.alb_listener]

  tags = {
    Name = "${var.cluster_name}-api-service"
  }
}

resource "aws_ecs_service" "auth" {
  name            = "auth-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight           = 100
  }

  network_configuration {
    security_groups  = [var.security_group_id]
    subnets         = var.subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.auth_target_group_arn
    container_name   = "auth-service"
    container_port   = 3001
  }

  depends_on = [var.alb_listener]

  tags = {
    Name = "${var.cluster_name}-auth-service"
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight           = 100
  }

  network_configuration {
    security_groups  = [var.security_group_id]
    subnets         = var.subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [var.alb_listener]

  tags = {
    Name = "${var.cluster_name}-frontend"
  }
}