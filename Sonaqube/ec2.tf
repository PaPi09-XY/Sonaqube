provider "aws" {
  region = "us-east-1"
  profile = "kay"
}


# create vpc

resource "aws_default_vpc" "default_vpc" {
    tags = {
        Name = "default_vpc"
    }
  
}

data "aws_availability_zones" "availability_zone" {}

#create default subnet
resource "aws_default_subnet" "default_Az1" {
availability_zone = data.aws_availability_zones.availability_zone.names [0]

tags = {
  Name = "default_subnet"

}
  
}

#create security group

resource "aws_security_group" "allow_web" {
  name        = "allow_web_sonaqube"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id
   
  

  ingress {
    description = "HTTP inbound rule"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

    ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "SSH inbound rule"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "allow_tls_SG"
  }

}

#ubuntu data source
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

  owners = ["099720109477"]
}

resource "aws_instance" "server4" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.medium"
  subnet_id     = aws_default_subnet.default_Az1.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  key_name      = "kay2"
  user_data = "${file("install_sonarqube.sh")}"
  tags = {
    Name = "sonarqube_server"
  }
}

# Print the URL of the SonarQube server
output "website_url" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "9000"])
}








