#**********************************
#**** Security Group Resources ****
#**********************************

# ---- Security Group for EC2 Amazon Linux Instances for InfluxDB  ----

resource "aws_security_group" "sg_influxdb" {
  name          = var.sg_name
  description   = var.sg_description
  vpc_id        = var.vpc
  tags = {
    Name        = var.sg_name
    Created_by  = "Terraform"
  }

  ingress {
    protocol = "tcp"
    from_port = 0
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 3000
    to_port = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
}