# Public subnet - Availability Zone A
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
    Tier = "public"
  }
}

# Public subnet - Availability Zone B
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
    Tier = "public"
  }
}

# Private application subnet
resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "app-subnet"
    Tier = "private"
  }
}

# Private database subnet - Availability Zone A
resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "database-subnet"
    Tier = "database"
  }
}

# Private database subnet - Availability Zone B
resource "aws_subnet" "database_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "database-subnet-b"
    Tier = "database"
  }
}