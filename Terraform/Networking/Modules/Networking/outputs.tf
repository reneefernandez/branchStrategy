###############################
#### Outputs VPC Resources ####
###############################

# ------ VPC ID ------
output "VPC_ID" {
    value = aws_vpc.clientVPC.id
}

# ------ Subnets Publics ------
output "SubnetPublics" {
    value = [aws_subnet.PublicsSubnets1.id,aws_subnet.PublicsSubnets2.id]
}

# ------ Subnets Private ------
output "SubnetPrivates" {
        value = [aws_subnet.PrivateSubnets1.id,aws_subnet.PrivateSubnets2.id]
}