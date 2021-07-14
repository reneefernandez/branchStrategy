# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #


provider "aws" {
  profile = "${var.Account_Name}" # Change this value for the profile with the credentials where you want to create a LandingPage
  region  = "${var.Region}"
}

# Account where you want to deploy 
# Vergninia region to ssl certificate used for CloudFront

provider "aws" {
  profile = "${var.Account_Name}" # Change this value for the profile with the credentials where you want to create a LandingPage
  region  = "us-east-1"
  alias   = "virginia"
}

#### Shared Services account
provider "aws" {
  alias   = "ss-account"
  profile = "sharedservices"
  region  = "${var.Region}"
}

#### Production account
provider "aws" {
  alias   = "prod-account"
  profile = "production"
  region  = "${var.Region}"
}

# # # # # # # # # # # # # # # # #
# # #   Get IDs - Section   # # #   
# # # # # # # # # # # # # # # # #

#Get values of reasources already  created by othres scripts

# ---- Get Accounts IDs -----
data "aws_caller_identity" "ID_Current_Account" {}

data "aws_caller_identity" "ID_SS_Account" {
  provider = "aws.ss-account"
}

# # # # # # # # # # # # # # # # # # # # # 
# # #    Modules Creation - Section   # # 
# # # # # # # # # # # # # # # # # # # # #

# ------------------------------------
# ---- Simple Email Service ( SES )---
# ------------------------------------
module "ses" {
  source  = "../Modules/SES"
  Domain  = "client.com"
  HostedZoneId = "Z3S5172K3LEJ3"
}