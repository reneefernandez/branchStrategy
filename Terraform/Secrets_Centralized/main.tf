# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #

provider "aws" {
  profile    = "${var.Account_Name}"
  region     = "${var.Region}"
}

#### SES #### 
module "SecretManagerSES" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-SES"
  retention_time = 30
}

#### SES #### 
module "SecretManagerIAM" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-IAM"
  retention_time = 30
}


