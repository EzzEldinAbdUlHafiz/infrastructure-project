resource "aws_db_subnet_group" "this" {
  name        = "${var.environment}-rds-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Private subnet group for RDS PostgreSQL"

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.environment}-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
  }
}