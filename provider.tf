# Configure the AWS Provider
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "us-east-1"
}

#Creating the VPC
resource "aws_vpc" "main" {
    cidr_block = "10.22.0.0/16"
    tags {
        Name = "openstack-vpc"
    }
}

#Creating Gateway and adding it to the VPC
resource "aws_internet_gateway" "default" {
	      vpc_id = "${aws_vpc.main.id}"
}

#Creating Subnets
resource "aws_subnet" "us-east-1a" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.22.0.0/24"
    availability_zone = "us-east-1a"

    tags {
        Name = "openstack-subnet-1a"
    }
}

resource "aws_subnet" "us-east-1b" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.22.1.0/24"
    availability_zone = "us-east-1b"

    tags {
        Name = "openstack-subnet-1b"
    }
}

#Creating Route table
resource "aws_route_table" "us-east-a" {
	vpc_id = "${aws_vpc.main.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}
}

resource "aws_route_table_association" "us-east-a" {
	subnet_id = "${aws_subnet.us-east-1a.id}"
	route_table_id = "${aws_route_table.us-east-a.id}"
}

resource "aws_route_table_association" "us-east-b" {
	subnet_id = "${aws_subnet.us-east-1b.id}"
	route_table_id = "${aws_route_table.us-east-a.id}"
}

#Create security group
resource "aws_security_group" "ssh" {
  name = "ssh"
    description = "Allow all ssh traffic"
  vpc_id = "${aws_vpc.main.id}"


  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "http" {
  name = "http"
    description = "Allow all http traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create the instance and install openstack with LXC support"
resource "aws_instance" "web" {
    ami = "${var.ami}"
    availability_zone = "us-east-1a"
    instance_type = "m4.large"
    key_name  = "${var.key_name}"
    subnet_id = "${aws_subnet.us-east-1a.id}"
    associate_public_ip_address = true
    security_groups = [ "${aws_security_group.ssh.id}", "${aws_security_group.http.id}" ]
    tags {
        Name = "Openstack-lxc"
    }
    root_block_device {
        volume_type = "standard"
        volume_size = "100"
        delete_on_termination = "true"
    }
    connection {
        user = "ubuntu"
        key_file = "${var.key_file}"
    }

#Copying sample openstack local.conf file to the instance
provisioner "file" {
    source = "local.conf"
    destination = "/tmp/local.conf"
  }

#Copying the setup script to the instance
provisioner "file" {
    source = "setup.sh"
    destination = "/tmp/setup.sh"
  }
#Executing the script
provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/setup.sh",
    "sh /tmp/setup.sh"
    ]
  }
}
