variable aws_region_virginia {
  default = "us-east-1"
}

variable ami_id {
  default = "ami-09d8b5222f2b93bf0"
}

variable key_name {
  default = "devops-test"
}

provider "aws" {
  region                  = "${var.aws_region_virginia}"
  shared_credentials_file = "/Users/pujitha/.aws/credentials"
  profile                 = "cdb-test"
}

# Using default VPC
resource "aws_default_vpc" "default_VPC" {
  tags = {
    Name = "Default VPC"
  }
}

# Using default Subnet
resource "aws_default_subnet" "default_subnet" {
  availability_zone = "us-east-1b"
}

# Security Group for Load Balancer
resource "aws_security_group" "load_balancer_sg" {
  name        = "ha_proxy_lb_sg"
  description = "Allow specified inbound traffic"
  vpc_id      = "${aws_default_vpc.default_VPC.id}"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["136.233.80.2/32"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Web Servers
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow specified inbound traffic"
  vpc_id      = "${aws_default_vpc.default_VPC.id}"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["136.233.80.2/32"]
  }

# Allow traffic only from the Load Balancer
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ha_proxy_lb.public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Launch 2 Web Servers
resource "aws_instance" "web_server_1" {
  ami                         = "${var.ami_id}"
  instance_type               = "t2.nano"
  vpc_security_group_ids      = ["${aws_security_group.web_server_sg.id}"]
  subnet_id                   =  "${aws_default_subnet.default_subnet.id}"
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  tags = {
    Name = "Hello-World-1"
  }
}

resource "aws_instance" "web_server_2" {
  ami                         = "${var.ami_id}"
  instance_type               = "t2.nano"
  vpc_security_group_ids      = ["${aws_security_group.web_server_sg.id}"]
  subnet_id                   =  "${aws_default_subnet.default_subnet.id}"
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  tags = {
    Name = "Hello-World-2"
  }
}

# Launch another Ec2 Instance which will be configured as Load Balancer using HAProxy
resource "aws_instance" "ha_proxy_lb" {
  ami                         = "${var.ami_id}"
  instance_type               = "t2.nano"
  vpc_security_group_ids      = ["${aws_security_group.load_balancer_sg.id}"]
  subnet_id                   =  "${aws_default_subnet.default_subnet.id}"
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  tags = {
    Name = "HA-Proxy-LB"
  }
}
