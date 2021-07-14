output "instance_ip_addr" {
    value = aws_instance.ec2_instance.*.private_ip
}

output "elk_instance_ip_addr" {
    value = aws_instance.ec2_elk_instance.*.private_ip
}
