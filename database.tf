# create db subnet group for aws rds instance
resource "aws_db_subnet_group" "a_rds_subnet_group" {
  name       = "a_rds_subnet_group"
  subnet_ids = module.aws_vpc_backend.private_subnets

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-rds-subnet-group" })
}


# create RDS instance
resource "aws_db_instance" "a_rds_instance" {
  identifier              = "${lower(local.naming_prefix)}-${var.environment}-rds-instance"
  allocated_storage       = var.aws_rds_allocated_storage
  engine                  = var.aws_rds_engine
  engine_version          = var.aws_rds_engine_version
  instance_class          = var.aws_rds_instance_class
  db_name                 = var.aws_rds_db_name
  username                = var.aws_rds_master_username
  password                = random_password.rds_password.result
  db_subnet_group_name    = aws_db_subnet_group.a_rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.a_rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  backup_retention_period = var.aws_rds_backup_retention_period
}