output "dev-lb-dns" {
  value = aws_lb.dev-lb.dns_name
}

output "prod-lb-dns" {
  value = aws_lb.prod-lb.dns_name
}