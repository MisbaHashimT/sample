output "alb_name" {
  value = aws_lb.my-alb.dns_name
}

output "availability_zone" {
  value = var.availability_zone

}