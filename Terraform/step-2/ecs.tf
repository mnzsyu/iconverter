data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "task-def" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.image_name}",
    "cpu": 256,
    "memory": 512,
    "name": "${var.app_name}-container",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "dev-ecs-cluster" {
  name = var.dev_cluster_name
}

resource "aws_ecs_cluster" "prod-ecs-cluster" {
  name = var.prod_cluster_name
}

resource "aws_ecs_service" "dev-ecs-service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.dev-ecs-cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.dev-app-sg.id]
    subnets = aws_subnet.dev-subnet-private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dev-ecs-tg.arn
    container_name   = "${var.app_name}-container"
    container_port   = var.app_port
  }

  depends_on = [aws_lb_listener.dev-lb-listener]
}

resource "aws_ecs_service" "prod-ecs-service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.prod-ecs-cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.prod-app-sg.id]
    subnets = aws_subnet.prod-subnet-private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prod-ecs-tg.arn
    container_name   = "${var.app_name}-container"
    container_port   = var.app_port
  }

  depends_on = [aws_lb_listener.prod-lb-listener]
}