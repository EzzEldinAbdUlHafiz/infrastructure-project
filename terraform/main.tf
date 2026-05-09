terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ── VPC ────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# ── Subnets ────────────────────────────────────────────────────────────────────

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.environment}-private-subnet-a"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.environment}-private-subnet-b"
    Environment = var.environment
  }
}

# ── Internet Gateway + Routing (public subnet needs this to reach the internet) ─

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── Modules ────────────────────────────────────────────────────────────────────

module "security_groups" {
  source            = "./modules/security_groups"
  vpc_id            = aws_vpc.main.id
  environment       = var.environment
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
}

module "ec2" {
  source             = "./modules/ec2"
  ami_id             = var.ami_id
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.security_groups.web_sg_id]
  key_name           = var.key_name
  instance_name      = var.app_name
  environment        = var.environment
  instance_type      = var.instance_type
}

module "rds" {
  source             = "./modules/rds"
  private_subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  rds_sg_id          = module.security_groups.rds_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  environment        = var.environment
}