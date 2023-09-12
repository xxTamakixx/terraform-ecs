########################################
# ECS Cluster
########################################
resource "aws_ecs_cluster" "webapp" {
  name = "webapp-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

########################################
# ECS Service
########################################
resource "aws_ecs_service" "webapp" {
  name = "webapp-service"

  launch_type                       = "FARGATE"
  cluster                           = aws_ecs_cluster.webapp.id
  task_definition                   = aws_ecs_task_definition.webapp.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 300

  network_configuration {
    assign_public_ip = true
    subnets = [
      aws_subnet.public_subnet_1a.id,
    ]
    security_groups = [
      aws_security_group.app_sg.id,
    ]
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.webapp.arn
    container_name   = "webapp"
    container_port   = 3000
  }
  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }
}

########################################
# ECS Task
########################################
resource "aws_ecs_task_definition" "webapp" {
  family = "webapp-template"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 # .25 vCPU
  memory                   = 512 # 512 MB
  execution_role_arn       = aws_iam_role.ecs_task_iam_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "webapp"
      image     = "${aws_ecr_repository.webapp.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      secrets = [
        {
          name      = "MYSQL_HOST"
          valueFrom = "${aws_ssm_parameter.host.arn}"
        },
        {
          name      = "MYSQL_PORT"
          valueFrom = "${aws_ssm_parameter.port.arn}"
        },
        {
          name      = "MYSQL_DATABASE"
          valueFrom = "${aws_ssm_parameter.database.arn}"
        },
        {
          name      = "MYSQL_USERNAME"
          valueFrom = "${aws_ssm_parameter.username.arn}"
        },
        {
          name      = "MYSQL_PASSWORD"
          valueFrom = "${aws_ssm_parameter.password.arn}"
        }
      ]
    }
  ])

}
