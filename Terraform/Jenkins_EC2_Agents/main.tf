# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #


provider "aws" {
  profile = "${var.Account_Name}" # Change this value for the profile with the credentials where you want to create a LandingPage
  region  = "${var.Region}"
}

# Account where you want to deploy 
# Vergninia region to ssl certificate used for CloudFront


# # # # # # # # # # # # # # # # #
# # #   Get IDs - Section   # # #   
# # # # # # # # # # # # # # # # #

#Get values of reasources already  created by othres scripts
# ---- Get Networking IDs -----

# ---- VPC  -----
data "aws_vpc" "vpc" {
  tags = {
    Name = "VPC_client_SS-Networking"
  }
}

# ---- Subnets   -----

# ---- Publics Subnets   -----
data "aws_subnet" "public_subnet1" {
  tags = {
    Name = "Subnet_SS-Networking_Public_1"
  }
}

data "aws_subnet" "public_subnet2" {
  tags = {
    Name = "Subnet_SS-Networking_Public_2"
  }
}

# ---- Privates Subnets   -----

data "aws_subnet" "private_subnet1" {
  tags = {
    Name = "Subnet_SS-Networking_Private_1"
  }
}

data "aws_subnet" "private_subnet2" {
  tags = {
    Name = "Subnet_SS-Networking_Private_2"
  }
}


# ----------------------
# --- SG Resources ----
# ----------------------


###########################################################
# AWS EC2
###########################################################
resource "aws_instance" "ec2_instance" {
  count = 2
  ami                    = "ami-0bf357e4bc8a8b9e3"
  subnet_id              =  data.aws_subnet.private_subnet1.id
  instance_type          = "t2.medium"
  # iam_instance_profile   = "${aws_iam_instance_profile.instance.name}"
  vpc_security_group_ids = ["sg-06e427059ef3c3c7f"] //jenkins sg
  key_name               = "SSKey_client"
  ebs_optimized          = "false"
  source_dest_check      = "false"
  user_data              = <<EOF
                #!/bin/bash
                sudo apt-get update -y
                # sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
                sudo apt install curl -y
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
                sudo apt update -y
                apt-cache policy docker-ce
                sudo apt install docker-ce -y
                sudo usermod -a -G docker ubuntu
                sudo add-apt-repository ppa:openjdk-r/ppa -y
                sudo apt install openjdk-8-jdk -y
                sudo useradd -m -s /bin/bash Jenkins
                EOF
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }

  tags = {
    Name = "SS-Jenkins-agent${count.index > 0 ? count.index : ""}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get update -y"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = "${self.private_ip}"
      private_key = "${file("~/Code/client/KEYS/ss-jenkins.rsa")}"
    }
  }

  provisioner "local-exec" {
      command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.private_ip},' jenkins-agents.yml -u ubuntu --private-key=~/Code/client/KEYS/ss-jenkins.rsa"
  }

  lifecycle {
    ignore_changes         = ["ami", "user_data", "subnet_id", "key_name", "ebs_optimized", "private_ip"]
  }
}

resource "aws_security_group" "sg_ec2_elk_instance" {
  name        = "ELK_${var.Environment}"
  description = "controls access to the ELK"
  vpc_id      = data.aws_vpc.vpc.id
  tags = {
    Name = "SG_ELK_${var.Environment}"
    Created_by = "Terraform"
  }

  dynamic "ingress" {
    for_each = toset(["5601", "9200", "5044"])
    content{
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["10.0.0.0/8"]
    }
  }

  dynamic "ingress" { 
    for_each = toset(["5601", "9200", "5044", "22"])
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      security_groups = ["sg-0a874bdbe76391713"] // open vpn sg
    }
  }

  dynamic "ingress" { 
    for_each = toset(["5601", "9200", "5044", "22"])
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      security_groups = ["sg-06e427059ef3c3c7f"] // jenkins sg
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_elk_instance" {
  count = 1
  ami                    = "ami-0bf357e4bc8a8b9e3"
  subnet_id              =  data.aws_subnet.private_subnet1.id
  instance_type          = "t2.medium"
  # iam_instance_profile   = "${aws_iam_instance_profile.instance.name}"
  vpc_security_group_ids = ["${aws_security_group.sg_ec2_elk_instance.id}"]
  key_name               = "SSKey_client"
  ebs_optimized          = "false"
  source_dest_check      = "false"
  user_data              = <<EOF
                #!/bin/bash
                sudo apt-get update -y
                # sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
                sudo apt update -y
                apt-cache policy docker-ce
                sudo apt-get install docker-ce -y
                sudo usermod -a -G docker ubuntu
                sudo sysctl -w vm.max_map_count=262144
                sudo docker run --rm -d -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk              
                EOF
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }

  tags = {
    Name = "ELK-Stack${count.index > 0 ? count.index : ""}"
  }

  lifecycle {
    ignore_changes         = ["ami", "user_data", "subnet_id", "key_name", "ebs_optimized", "private_ip"]
  }
}