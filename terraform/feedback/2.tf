# Create NAT gateway
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

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gettrx_nat_1.id
  }

  tags = {
    Name = "gettrx-private-rt"
  }
}