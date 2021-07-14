# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #

provider "aws" {
  profile    = "${var.Account_Name}"
  region     = "${var.Region}"
}

provider "aws" {
  alias = "ss-account"
  profile    = "sharedservices"
  region     = "us-west-2"
}


# # # # # # # # # # # # # #
# # #   VPC creation  # # #
# # # # # # # # # # # # # #

# We have two variables with the CIDR for VPC and Subnets, according to the account where you will launch the resources, we will select the 
# CIDR Block 
module "networking_latest" {
  source         = "./Modules/Networking"
  CIDR           = [(var.Account_Name == "latest" ? "${var.CIDR_Blocks_Latest[0]}" : (var.Account_Name == "production" ? "${var.CIDR_Blocks_Production[0]}" : "${var.CIDR_Blocks_Dev[0]}"))]
  Environment    = "${var.Environment}"
  Account_Name   = "${var.Account_Name}"
  TransitGateway = "tgw-042728ed6604bef47"
}