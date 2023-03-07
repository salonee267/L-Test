resource "aws_db_instance" "test_rds" {
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  skip_final_snapshot  = true
  identifier           = "testdb"
  allocated_storage    = 10
  db_name              = "testdb"
  publicly_accessible  = true
  username             = "admin"
  password             = "password"
  vpc_security_group_ids = [ aws_security_group.rds_sec_grp.id]

  provisioner "local-exec" {
    command = "mysql -h ${aws_db_instance.test_rds.address} -P 3306 -u admin -ppassword < my_table.sql"
  }
}

resource "aws_security_group" "rds_sec_grp" {
  name_prefix = "example-sg"
  

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # other ingress and egress rules go here ##TODO: add more later
}