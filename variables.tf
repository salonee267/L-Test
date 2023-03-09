variable "identifier" {
  description = "name of database identifier- this name will reflect in AWS console"
  type        = string
  default     = "testdb"
}

variable "allocated_storage" {
  description = "allocated storage for the db"
  type        = number
  default     = 10
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "testdb"
}

variable "username" {
  description = "Username for the DB user"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Password for the DB user"
  type        = string
  default     = "password"
}

variable "bucket_name" {
  description = "name of the bucket"
  type        = string
  default     = "lep-demo-s3-bucket-1234"
}

variable "lambda_role" {
  description = "arn of the lambda role for S3 and RDS"
  type        = string
#   default     = "arn:aws:iam::645240902082:role/LambdaRoleForS3andRDS"
  default     = "arn:aws:iam::058399968204:role/LambdaRoleForS3andRDS_prod"
}




