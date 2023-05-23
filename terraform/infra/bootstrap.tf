
# Create VPC
resource "aws_vpc" "gettrx_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "gettrx-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "gettrx_public_subnet_1" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.0.0/24"  # 254 usable IP addresses
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "gettrx-public-1"
  }
}

resource "aws_subnet" "gettrx_public_subnet_2" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.1.0/24"  # 254 usable IP addresses
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "gettrx-public-2"
  }
}

# Create private subnets
resource "aws_subnet" "gettrx_private_subnet_1" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.2.0/24"  # 254 usable IP addresses
  availability_zone       = var.availability_zones[0]

  tags = {
    Name = "gettrx-private-1"
  }
}

resource "aws_subnet" "gettrx_private_subnet_2" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.3.0/24"  # 254 usable IP addresses
  availability_zone       = var.availability_zones[1]

  tags = {
    Name = "gettrx-private-2"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "gettrx_igw" {
  vpc_id = aws_vpc.gettrx_vpc.id

  tags = {
    Name = "gettrx-igw"
  }
}

# Create NAT gateways
resource "aws_eip" "gettrx_eip_1" {
  vpc = true

  tags = {
    Name = "gettrx-nat-1-eip"
  }
}

resource "aws_nat_gateway" "gettrx_nat_1" {
  subnet_id     = aws_subnet.gettrx_public_subnet_1.id
  allocation_id = aws_eip.gettrx_eip_1.id

  tags = {
    Name = "gettrx-nat-1"
  }
}

resource "aws_eip" "gettrx_eip_2" {
  vpc = true

  tags = {
    Name = "gettrx-nat-2-eip"
  }
}

resource "aws_nat_gateway" "gettrx_nat_2" {
  subnet_id     = aws_subnet.gettrx_public_subnet_2.id
  allocation_id = aws_eip.gettrx_eip_2.id

  tags = {
    Name = "gettrx-nat-2"
  }
}

# Create route tables
resource "aws_route_table" "gettrx_public_rt" {
  vpc_id = aws_vpc.gettrx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gettrx_igw.id
  }

  tags = {
    Name = "gettrx-public-rt"
  }
}

resource "aws_route_table" "gettrx_private_rt" {
  vpc_id = aws_vpc.gettrx_vpc.id

  tags = {
    Name = "gettrx-private-rt"
  }
}

resource "aws_route_table_association" "gettrx_public_subnet_1_association" {
  subnet_id      = aws_subnet.gettrx_public_subnet_1.id
  route_table_id = aws_route_table.gettrx_public_rt.id
}

resource "aws_route_table_association" "gettrx_public_subnet_2_association" {
  subnet_id      = aws_subnet.gettrx_public_subnet_2.id
  route_table_id = aws_route_table.gettrx_public_rt.id
}

resource "aws_route_table_association" "gettrx_private_subnet_1_association" {
  subnet_id      = aws_subnet.gettrx_private_subnet_1.id
  route_table_id = aws_route_table.gettrx_private_rt.id
}

resource "aws_route_table_association" "gettrx_private_subnet_2_association" {
  subnet_id      = aws_subnet.gettrx_private_subnet_2.id
  route_table_id = aws_route_table.gettrx_private_rt.id
}

# Create security group for the load balancer
resource "aws_security_group" "gettrx_loadbalancer_sg" {
  vpc_id = aws_vpc.gettrx_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gettrx-loadbalancer-sg"
  }
}

# Create the Application Load Balancer
resource "aws_lb" "gettrx_loadbalancer" {
  name               = "gettrx-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.gettrx_loadbalancer_sg.id]
  subnets            = [aws_subnet.gettrx_public_subnet_1.id, aws_subnet.gettrx_public_subnet_2.id]

  tags = {
    Name = "gettrx-loadbalancer"
  }
}

# Create listeners for the Application Load Balancer
resource "aws_lb_listener" "gettrx_listener_80" {
  load_balancer_arn = aws_lb.gettrx_loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "gettrx_listener_443" {
  load_balancer_arn = aws_lb.gettrx_loadbalancer.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gettrx_tg.arn
  }
}

# Create a target group for the load balancer
resource "aws_lb_target_group" "gettrx_tg" {
  name        = "gettrx-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.gettrx_vpc.id

  health_check {
    path = "/api"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.gettrx_tg.arn
  target_id        = aws_instance.ec2_instance.id
  port             = 80
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key" {
  key_name   = "gettrx-ssh-key"
  public_key = tls_private_key.key.public_key_openssh
}


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Create the EC2 instance
resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type
  key_name      = aws_key_pair.aws_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y ansible awscli unzip
              aws s3 cp s3://gettrx-bucket/ansible.zip /home/ubuntu/
              unzip /home/ubuntu/ansible.zip -d /home/ubuntu/
              ansible-playbook /home/ubuntu/playbook.yml
              EOF

  tags = {
    Name = "gettrx-instance"
  }
}


# Database subnet group
resource "aws_db_subnet_group" "database" {
  name       = "gettrx-database-subnet-group"
  subnet_ids = [aws_subnet.gettrx_private_subnet_1.id, aws_subnet.gettrx_private_subnet_2.id]

  tags = {
    Name = "gettrx-database-subnet-group"
  }
}

# Security group for RDS
resource "aws_security_group" "gettrx_database_sg" {
  vpc_id = aws_vpc.gettrx_vpc.id

  ingress {
    from_port   = 5432 # PostgreSQL port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Access only from the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gettrx-database-sg"
  }
}


# Database parameter group
resource "aws_db_parameter_group" "gettrx_database_parameter_group" {
  name   = "gettrx-database-parameter-group"
  family = "postgres13"

  parameter {
    name  = "shared_buffers"
    value = "8192"
  }

  parameter {
    name  = "effective_cache_size"
    value = "32768"
  }

  parameter {
    name  = "work_mem"
    value = "16384"
  }

  tags = {
    Name = "gettrx-database-parameter-group"
  }
}

# Database option group
resource "aws_db_option_group" "gettrx_database_option_group" {
  name                     = "gettrx-database-option-group"
  option_group_description = "Option group for gettrx database"
  engine_name              = "postgres"
  major_engine_version     = "13"

  tags = {
    Name = "gettrx-database-option-group"
  }
}

# RDS instance
resource "aws_db_instance" "gettrx_database" {
  identifier            = "gettrx-database"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "13.3"
  instance_class        = "db.t2.micro"
  username              = "admin" # change the user here
  password              = "password" # change the password here
  db_subnet_group_name  = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.gettrx_database_sg.id]
  skip_final_snapshot   = false
  final_snapshot_identifier = "gettrx-database-final-snapshot"
  backup_retention_period = 7 # 7 days of backups
  backup_window = "04:00-06:00" # Backup window
  maintenance_window = "Mon:00:00-Mon:03:00" # Maintenance window
  multi_az = true # Enable multi-az for high availability
  storage_encrypted = true # Encrypt storage
  kms_key_id = aws_kms_key.gettrx_kms_key.arn # KMS key for encryption
  performance_insights_enabled = true # Enable performance insights
  parameter_group_name = aws_db_parameter_group.gettrx_database_parameter_group.name
  option_group_name = aws_db_option_group.gettrx_database_option_group.name

  tags = {
    Name = "gettrx-database"
  }
}

# KMS key for storage encryption
resource "aws_kms_key" "gettrx_kms_key" {
  description             = "KMS key for gettrx database"
  deletion_window_in_days = 10
}