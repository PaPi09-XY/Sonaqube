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
  name        = "allow_web"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTPS web traffice from vpc"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  ingress {
    description = "HTTP inbound rule"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  ingress {
    description = "HTTP inbound rule"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
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

#create tomcat server
resource "aws_instance" "server2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_default_subnet.default_Az1.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  key_name = "kay2"
  user_data = "${file("install_tomacat.sh")}"

  tags = {
    Name = "tomcat_server"
  }

}

# print the url of the tomcat server
output "Tomcat_website_url" {
  value     = join ("", ["http://", aws_instance.server2.public_ip, ":", "8080"])
  description = "Tomcat Server is server2"
}



#output "website-url" {
 # value       = "${aws_instance.server2.*.public_ip}"
  #description = "PublicIP address details"
#}
# aws_instance.ec2_instance_instance.public_dns




