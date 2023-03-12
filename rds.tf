data "template_file" "input" {
  template = "my_table.sql"
  vars = {
    db_name = var.db_name
    table_name = var.table_name
  }
}

resource "aws_db_instance" "test_rds" {
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  skip_final_snapshot  = true
  identifier           = var.identifier
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  publicly_accessible  = true
  username             = var.username
  password             = var.password
  vpc_security_group_ids = [ aws_security_group.rds_sec_grp.id]

  provisioner "local-exec" {
    # command = "mysql -h ${aws_db_instance.test_rds.address} -P 3306 -u ${var.username} -p${var.password} < my_table.sql"
    command = "mysql -h ${aws_db_instance.test_rds.address} -P 3306 -u ${var.username} -p${var.password} < ${data.template_file.input.rendered}"
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
