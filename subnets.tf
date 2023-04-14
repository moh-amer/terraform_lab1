data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_subnet" "public_subnet01" {
  vpc_id            = aws_vpc.vpctf.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "public-subnet01"
  }
}

resource "aws_subnet" "public_subnet02" {
  vpc_id            = aws_vpc.vpctf.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "public-subnet02"
  }

}

resource "aws_subnet" "private_subnet01" {
  vpc_id            = aws_vpc.vpctf.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "private-subnet01"
  }
}

resource "aws_subnet" "private_subnet02" {
  vpc_id            = aws_vpc.vpctf.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "private-subnet02"
  }
}
