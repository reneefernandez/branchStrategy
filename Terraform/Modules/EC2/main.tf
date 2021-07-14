#**************************************
#************  EC2 Resources **********
#***************************************

resource "aws_instance" "ec2_instance" {

#************ AMI **********
#***************************************
  ami = "${var.ami}"

  instance_type = "${var.Instace_type}"
  iam_instance_profile = "${var.iam_instance_profile}"

  tags = {
    Name = "${var.Name}"
    Created_by = "Terraform"
  }

  # Delete EBS volume after instance is destroyed 
  root_block_device {
    delete_on_termination = true
  }

#************  Security group **********
#***************************************
  vpc_security_group_ids      = "${var.Security_groups}"

#************  Subnets **********
#***************************************
#Subnets should be gotten using data sources
  subnet_id                   = "${var.Subnets[0]}" 

  # Keypair to use in the ec2 instance
  key_name = "${var.PublicKeySS}"

}