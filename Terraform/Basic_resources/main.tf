# Account where you want to deploy 
provider "aws" {
  profile = var.Account_Name
  region  = var.Region
}

# Virginia region is used to ssl certificate used for CloudFront

provider "aws" {
  profile = var.Account_Name # Change this value for the profile with the credentials where you want to create a LandingPage
  region  = "us-east-1"
  alias   = "virginia"
}

#### Shared Services account
provider "aws" {
  alias   = "ss-account"
  profile = "sharedservices"
  region  = var.Region
}

#### Production account
provider "aws" {
  alias   = "prod-account"
  profile = "production"
  region  = var.Region
}

# # # # # # # # # # # # # # # # #
# # #   Get IDs - Section   # # #
# # # # # # # # # # # # # # # # #

#Get values of reasources already created by other scripts

# ---- Get Accounts IDs -----
data "aws_caller_identity" "ID_Current_Account" {}

data "aws_caller_identity" "ID_SS_Account" {
  provider = aws.ss-account
}

# ---- Route53 Zones ID client.com

data "aws_route53_zone" "main_zone" {
  name     = "client.com."
  provider = aws.prod-account
}

# ---- Route53 Zones ID test.client.com

data "aws_route53_zone" "test_zone" {
  name     = "test.client.com."
  provider = aws.prod-account
}

# ---- Route53 Zones ID latest.client.com

data "aws_route53_zone" "latest_zone" {
  name     = "latest.client.com."
  provider = aws.prod-account
}

# ---- Get Networking IDs -----

# ---- VPC  -----
data "aws_vpc" "vpc" {
  tags = {
    Name = "VPC_client_${var.Account_Name}"
  }
}
# ---- Subnets   -----

# ---- Publics Subnets   -----
data "aws_subnet" "public_subnet1" {
  tags = {
    Name = "Subnet_Public1_${var.Account_Name}"
  }
}

data "aws_subnet" "public_subnet2" {
  tags = {
    Name = "Subnet_Public2_${var.Account_Name}"
  }
}

# ---- Private Subnets   -----
data "aws_subnet" "private_subnet1" {
  tags = {
    Name = "Subnet_Private1_${var.Account_Name}"
  }
}

data "aws_subnet" "private_subnet2" {
  tags = {
    Name = "Subnet_Private2_${var.Account_Name}"
  }
}

module "Cluster-ECS" {
  source      = "../Modules/ECS-Cluster"
  for_each    = toset(var.Environment)
  Environment = "microservices-${each.value}"
}