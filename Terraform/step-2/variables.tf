variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "app_name" {
  type = string
}

variable "app_port" {
  type = number
}

variable "image_name" {
  type = string
}

variable "dev_cluster_name" {
  type    = string
  default = "dev"
}

variable "prod_cluster_name" {
  type    = string
  default = "prod"
}

variable "app_count" {
  type    = number
  default = 2
}