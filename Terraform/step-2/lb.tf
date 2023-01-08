resource "aws_lb" "dev-lb" {
  name            = "dev-lb"
  subnets         = aws_subnet.dev-subnet-public.*.id
  security_groups = [aws_security_group.dev-lb-sg.id]
}

resource "aws_lb_target_group" "dev-ecs-tg" {
  name        = "dev-ecs-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dev-vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "dev-lb-listener" {
  load_balancer_arn = aws_lb.dev-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.dev-ecs-tg.id
    type             = "forward"
  }
}

resource "aws_lb" "prod-lb" {
  name            = "prod-lb"
  subnets         = aws_subnet.prod-subnet-public.*.id
  security_groups = [aws_security_group.prod-lb-sg.id]
}

resource "aws_lb_target_group" "prod-ecs-tg" {
  name        = "prod-ecs-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod-vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "prod-lb-listener" {
  load_balancer_arn = aws_lb.prod-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.prod-ecs-tg.id
    type             = "forward"
  }
}