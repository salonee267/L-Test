output "endpoint" {
  description = "The RDS connection endpoint"
  value       = aws_db_instance.test_rds.endpoint
}