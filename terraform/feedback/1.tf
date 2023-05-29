# Create public subnets
resource "aws_subnet" "gettrx_public_subnet_1" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.0.0/22"  # 1021 usable IP addresses
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "gettrx-public-1"
  }
}

resource "aws_subnet" "gettrx_public_subnet_2" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.4.0/22"  # 1021 usable IP addresses
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "gettrx-public-2"
  }
}

# Create private subnets
resource "aws_subnet" "gettrx_private_subnet_1" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.8.0/22"  # 1021 usable IP addresses
  availability_zone       = var.availability_zones[0]

  tags = {
    Name = "gettrx-private-1"
  }
}

resource "aws_subnet" "gettrx_private_subnet_2" {
  vpc_id                  = aws_vpc.gettrx_vpc.id
  cidr_block              = "10.0.12.0/22"  # 1021 usable IP addresses
  availability_zone       = var.availability_zones[1]

  tags = {
    Name = "gettrx-private-2"
  }
}
