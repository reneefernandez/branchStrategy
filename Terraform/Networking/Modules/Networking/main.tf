#*************************
#***  VPC  Resources *****
#*************************

provider "aws" {
  alias = "ss-account"
  profile    = "sharedservices"
  region     = "us-west-2"
}

 provider "aws" {
   profile    = "latest"
   region     = "us-west-2"
 }
#-------- Create VPC  --------

resource "aws_vpc" "clientVPC" {
  cidr_block           = "${var.CIDR[0]}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   =  true
  tags = {
     Name = "VPC_client_${var.Environment}"
     Created_by = "Terraform"
  }
}


# Get Region Available Zones

data "aws_availability_zones" "available" {
  state = "available"
}

# Create subnets in the first two available availability zones
# 2 Private Subnets
# 2 Public Subnets

#------- Public Subnets -------

# --- First Public Subnet
resource "aws_subnet" "PublicsSubnets1" {
      availability_zone       = "${data.aws_availability_zones.available.names[0]}"
      vpc_id                  = "${aws_vpc.clientVPC.id}"
      cidr_block              = "${cidrsubnet(aws_vpc.clientVPC.cidr_block, 7, 0)}"
      map_public_ip_on_launch = true
      tags = {
        Name = "Subnet_Public1_${var.Environment}"
        Created_by = "Terraform"
      }
}
# --- Second Public Subnet
resource "aws_subnet" "PublicsSubnets2" {
      availability_zone       = "${data.aws_availability_zones.available.names[1]}"
      vpc_id                  = "${aws_vpc.clientVPC.id}"
      cidr_block              = "${cidrsubnet(aws_vpc.clientVPC.cidr_block, 7, 1)}"
      map_public_ip_on_launch = true
      tags = {
        Name = "Subnet_Public2_${var.Environment}"
        Created_by = "Terraform"
      }
}

#------- Private Subnets -------

# --- First Private Subnet
resource "aws_subnet" "PrivateSubnets1" {
      availability_zone       = "${data.aws_availability_zones.available.names[0]}"
      vpc_id                  = "${aws_vpc.clientVPC.id}"
      cidr_block              = "${cidrsubnet(aws_vpc.clientVPC.cidr_block, 7, 2)}"
      tags = {
        Name = "Subnet_Private1_${var.Environment}"
        Created_by = "Terraform"
      }
}

# --- Second Private Subnet
resource "aws_subnet" "PrivateSubnets2" {
      availability_zone       = "${data.aws_availability_zones.available.names[1]}"
      vpc_id                  = "${aws_vpc.clientVPC.id}"
      cidr_block              = "${cidrsubnet(aws_vpc.clientVPC.cidr_block, 7, 3)}"
      tags = {
        Name = "Subnet_Private2_${var.Environment}"
        Created_by = "Terraform"
      }
}

#------- Launch Internet Gateway -------

resource "aws_internet_gateway" "clientIGW" {
      vpc_id = "${aws_vpc.clientVPC.id}"
      tags   = {
         Name = "IGW_${var.Environment}"
         Created_by = "Terraform"
      }
}

#------- Create Default Route Public Table -------

resource "aws_default_route_table" "clientRTPublic" {
      default_route_table_id = "${aws_vpc.clientVPC.default_route_table_id}"
      
      ### Internet Route
      route {
         cidr_block = "0.0.0.0/0"
         gateway_id = "${aws_internet_gateway.clientIGW.id}"
      }
      ### ShareService Route
      route {
         cidr_block = "10.11.0.0/16"
         transit_gateway_id = "${var.TransitGateway}"
      }
      ### client Route Route
      route {
         cidr_block = "10.2.0.0/16"
         transit_gateway_id = "${var.TransitGateway}"
      }
      ### Production or Latest Route
      route {
         cidr_block = (var.Account_Name == "latest" ? "10.13.0.0/16" : "10.12.0.0/16")
         transit_gateway_id = "${var.TransitGateway}"
      }

      tags = {
        Name = "Public_RT_${var.Environment}"
        Created_by = "Terraform"
      }
}

#------- Create EIP -------
resource "aws_eip" "clientEIPNAT" {
    vpc      = true
}

#------- Attach EIP to Nat Gateway -------
resource "aws_nat_gateway" "clientNAT" {
      allocation_id = "${aws_eip.clientEIPNAT.id}"
      subnet_id     = "${aws_subnet.PublicsSubnets2.id}"
      tags = {
        Name = "NAT_${var.Environment}"
        Created_by = "Terraform"
      }
}

#------- Create Private Route Private Table -------
resource "aws_route_table" "clientRTPrivate" {
        vpc_id = "${aws_vpc.clientVPC.id}"

      ### Internet Route  
      route {
          cidr_block = "0.0.0.0/0"
          gateway_id = "${aws_nat_gateway.clientNAT.id}"
        }
      ### ShareService Route
      route {
         cidr_block = "10.11.0.0/16"
         transit_gateway_id = "${var.TransitGateway}"
      }
      ### client Route
      route {
         cidr_block = "10.2.0.0/16"
         transit_gateway_id = "${var.TransitGateway}"
      }
      ### Production or Latest Route
      route {
         cidr_block = (var.Account_Name == "latest" ? "10.13.0.0/16" : "10.12.0.0/16")
         transit_gateway_id = "${var.TransitGateway}"
      }

        tags = {
          Name = "Private_RT_${var.Environment}"
          Created_by = "Terraform"
        }
        depends_on = [aws_nat_gateway.clientNAT]
}
#------- Private Subnets Association -------
resource "aws_route_table_association" "RTAssociatonPrivate1" {
  subnet_id      = "${aws_subnet.PrivateSubnets1.id}"
  route_table_id = "${aws_route_table.clientRTPrivate.id}"
  depends_on     = [aws_route_table.clientRTPrivate]
}
resource "aws_route_table_association" "RTAssociatonPrivate2" {
  subnet_id      = "${aws_subnet.PrivateSubnets2.id}"
  route_table_id = "${aws_route_table.clientRTPrivate.id}"
  depends_on     = [aws_route_table.clientRTPrivate]
}

#------- Public Subnets Association -------
resource "aws_route_table_association" "RTAssociatonPublic1" {
  subnet_id      = "${aws_subnet.PublicsSubnets2.id}"
  route_table_id = "${aws_vpc.clientVPC.main_route_table_id}"
} 
resource "aws_route_table_association" "RTAssociatonPublic2" {
  subnet_id      = "${aws_subnet.PublicsSubnets2.id}"
  route_table_id = "${aws_vpc.clientVPC.main_route_table_id}"
} 
