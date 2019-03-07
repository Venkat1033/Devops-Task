resource "aws_key_pair" "main" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjTvaisPsGbEIEYjsnFoHOoSy7YJmU4SL7Q3xg5aRcgRPFLNUH4diqFEVsucLN3a21fTTj7SzgaP+Bfg04acZOkV9aPMoBGyPuGVGFh2Pbz5zWADI7mtS3kiPBDRv3KL4tJrxT2wlTFdQ2Ud4R2DnW+O+aqvbrnAjx8+KLFIN9YmiwJo0rmhAy1IXKw4wL5jia6rhTkSDGFDvAH6tt31kcuDUvTP63mXg4RdVGigVFJn7BlB02XBOuP7WVjYFspbGE4Z87Wf3u9b7Po/xP+OiODKuXH56Hg+L0wOVlAPt2YS06Pu2t0WXYUe+wjmtKDAVk5bcpfVizmM36Vs/eNKlp root@ubunt"
 }

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags {
        Name = "Devops"
    }

}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
        Name = "Devops"
    }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags {
        Name = "Devops"
    }
 
}


resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
       }
    tags {
        Name = "Devops"
    }
}


resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.my_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web" {
  
  count= 2

  subnet_id = "${aws_subnet.my_subnet.id}"

  instance_type = "t2.micro"
  ami = "ami-04ea996e7a3e7ad6b"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  key_name = "${aws_key_pair.main.key_name}"
  user_data = "${file("hostname${count.index+1}.sh")}"

  tags {
    "Name" = "Devops${count.index+1}"
  }
}
