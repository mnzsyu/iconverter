resource "aws_ecr_repository" "ecr_repository" {
  name = var.app_name

  image_scanning_configuration {
    scan_on_push = true
  }
}
