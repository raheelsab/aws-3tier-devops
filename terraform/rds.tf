# RDS subnet group
# The database is placed in private subnets across two Availability Zones.

resource "aws_db_subnet_group" "app" {
  name = "app-db-subnet-group"

  subnet_ids = [
    aws_subnet.database.id,
    aws_subnet.database_b.id
  ]

  tags = {
    Name = "app-db-subnet-group"
    Tier = "database"
  }
}

# PostgreSQL database
# The database is private and accepts traffic only through database-sg.

resource "aws_db_instance" "app" {
  identifier = "app-database"

  engine         = "postgres"
  engine_version = "17"

  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "appdb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.database.id]

  publicly_accessible = false

  backup_retention_period = 0

  multi_az = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "app-database"
    Tier = "database"
  }
}