resource "aws_vpc" "vpc" {
  cidr_block = "172.20.0.0/16"
  tags = {
    Name = "devopsvpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "172.20.10.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "devops-public-sub"
  }
}


resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "172.20.20.0/24"
  tags = {
    Name = "devops-private-sub"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "devops-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
  }
tags = {
    Name = "public-rt"
  }
}



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
tags =  {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rta_subnet_private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "sg" {
  name = "sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 8080
      to_port     = 8080
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
    Name = "devops-sg"
  }
}

resource "aws_eip" "eip" {
vpc      = true
}

#natgateway

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.private.id
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "devops-nat"
   }
}


#Ec2

resource "aws_instance" "jenkins" {
  ami = "ami-0a23ccb2cdd9286bb"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  key_name = "project"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data = "${file("script.sh")}"
  tags = {
    Name = "jenkins"
}
}
