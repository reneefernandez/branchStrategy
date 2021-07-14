#***************************
#***  Auto Scaling EC2 *****
#***************************

# Template for autoscaling group
resource "aws_launch_template" "ec2_template" {
  name_prefix   = "${var.Environment}-template"
  image_id      = "${var.AMI}"
  instance_type = "${var.Instace_type}"
  key_name      = "${var.KeyPair}"
  vpc_security_group_ids = "${var.SecurityGroup}"
  tags = {
    Name = "${var.Environment}-template"
    Created_by = "Terraform"
  }
}

resource "aws_autoscaling_group" "auto_scaling" {
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier = "${var.Subnets}"
  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }
  tags = concat(
    [
      {
        key = "Name"
        value = "${var.Environment}-asg"
        "propagate_at_launch" = true
      },
      {
        key = "Created_by"
        value = "Terraform"
        "propagate_at_launch" = true
      },
    ]
  )
}