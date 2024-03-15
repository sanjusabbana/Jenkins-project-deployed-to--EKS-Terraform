resource "aws_vpc" "VPC-EKS-project" {
  cidr_block = var.Vpc-cidr_block
}

resource "aws_internet_gateway" "project-Eks_IG" {
  vpc_id = aws_vpc.VPC-EKS-project.id
}

resource "aws_subnet" "EKS_pub_sub1" {
  vpc_id = aws_vpc.VPC-EKS-project.id
  cidr_block = var.pub-sub1
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "EKS_pub_sub2" {
  vpc_id = aws_vpc.VPC-EKS-project.id
  cidr_block = var.pub-sub2
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

#resource "aws_subnet" "Eks_pvt_sub1" {
# vpc_id = aws_vpc.VPC-EKS-project
#  cidr_block = var.pvt-sub1
# availability_zone = "us-east-1a"
#  map_public_ip_on_launch = true
#}

#resource "aws_subnet" "Eks_pvt_sub2" {
#  vpc_id = aws_vpc.VPC-EKS-project
#  cidr_block = var.pvt-sub2
#  availability_zone = "us-east-1b"
# map_public_ip_on_launch = true
#}

resource "aws_route_table" "Eks_RT1" {
  vpc_id = aws_vpc.VPC-EKS-project.id

  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_internet_gateway.project-Eks_IG.id
  }

}

resource "aws_security_group" "Eks_SG1" {
    vpc_id = aws_vpc.VPC-EKS-project.id

    ingress {
        description  = "ssh"
        from_port    = 22
        to_port      = 22
        protocol     = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]

    }

     ingress {
        description  = "HTTP for vpc"
        from_port    = 80
        to_port      = 80
        protocol     = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]

    }

     egress {
        description  = "all traffic"
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
  
}

# Ec2-instances configuration for jenkins server

resource "aws_instance" "EKs_ec2_jenkins1" {
  ami                     = var.ec2_ami
  instance_type           = var.instance_type
  vpc_security_group_ids = [aws_security_group.Eks_SG1.id]
  subnet_id = aws_subnet.EKS_pub_sub1.id
 # user_data = base64encode(file("jenkins-user-data.sh"))
}

resource "aws_instance" "EKs_ec2_jenkins2" {
  ami                     = var.ec2_ami
  instance_type           = var.instance_type
  vpc_security_group_ids = [aws_security_group.Eks_SG1.id]
  subnet_id = aws_subnet.EKS_pub_sub2.id
  user_data = base64encode(file("jenkins-user-data.sh"))

}




