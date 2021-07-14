# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #

# Local configs 
locals {
  replication_source_region           = "${var.Region}"
  replication_destination_region      = "${var.Region_replication}"
}

# Account where you want to deploy 
# For general use
provider "aws" {
  profile    = "${var.Account_Name}"   
  region     = local.replication_source_region
}

# For replication use
provider "aws" {
  profile    = "${var.Account_Name}"   
  region     = local.replication_destination_region
  alias      = "replica"
}

#---------- State Recovery ----------

# Recover already created KMS key
data "aws_kms_key" "backups_key" {
  key_id = "66ff798f-c7f7-4f4a-957d-e56f166be5fa"
}

# # # # # # # # # # # # # # # # # # # # # 
# # #    Modules Creation - Section   # # 
# # # # # # # # # # # # # # # # # # # # #

# ----------------
# --- KMS Keys ---
# ----------------

module "KMS_Encrypt" {
  source     = "../Modules/KMS"
  Key_Name   = "Key_client_BKs" 
  Alias_Name = "alias/Key_client_BKs"
  Policy     = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::561491151124:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
POLICY
}

module "KMS_Encrypt_BCP" {
  source     = "../Modules/KMS"
  Key_Name   = "Key_client_BKs_BCP"
  Alias_Name = "alias/Key_client_BKs_BCP"
  providers = {
    aws = "aws.replica"
  }   
  Policy     = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::561491151124:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
POLICY
}

# ------------------------
# --- Bucket Resources ---
# ------------------------

module "S3_Backups_BCP" {
  source             = "./Modules/S3_Bucket"
  Bucket_Name        = "backups-client-production-bcp"
  Enable_Replication = false
  KMS_replication    = module.KMS_Encrypt_BCP.KMS_Key
  providers = {
    aws = "aws.replica"
  }
  Policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:Delete*",
            "Resource": [
                "arn:aws:s3:::backups-client-production-bcp",
                "arn:aws:s3:::backups-client-production-bcp/*"
            ]
        }
    ]
}
  POLICY
}

module "S3_Backups_Latest_bcp" {
  source             = "./Modules/S3_Bucket"
  Bucket_Name        = "backups-client-latest-bcp"
  Enable_Replication = false
  KMS_replication    = module.KMS_Encrypt_BCP.KMS_Key
  providers = {
    aws = "aws.replica"
  }
  Policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:Delete*",
            "Resource": [
                "arn:aws:s3:::backups-client-latest-bcp",
                "arn:aws:s3:::backups-client-latest-bcp/*"
            ]
        }
    ]
}
  POLICY
}

module "S3_Backups" {
  source                         = "./Modules/S3_Bucket"
  Bucket_Name                    = "backups-client-production"
  Enable_Replication             = true
  Replication_Destination_bucket = module.S3_Backups_BCP.bucket_arn
  Replication_role               = module.IAM_Production_bcp.replication_role_arn
  KMS_origin                     = "${data.aws_kms_key.backups_key.key_id}"
  KMS_replication_ARN            = module.KMS_Encrypt_BCP.KMS_Key_ARN
  Policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::178286397538:user/JenkinsSecret"
            },
            "Action": "s3:Put*",
            "Resource": [
                "arn:aws:s3:::backups-client-production",
                "arn:aws:s3:::backups-client-production/*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:Delete*",
            "Resource": [
                "arn:aws:s3:::backups-client-production",
                "arn:aws:s3:::backups-client-production/*"
            ]
        }
    ]
}
  POLICY
}

module "S3_Backups_Latest" {
  source                         = "./Modules/S3_Bucket"
  Bucket_Name                    = "backups-client-latest"
  Enable_Replication             = true 
  Replication_Destination_bucket = module.S3_Backups_Latest_bcp.bucket_arn
  Replication_role               = module.IAM_Latest_bcp.replication_role_arn
  KMS_origin                     = "${data.aws_kms_key.backups_key.key_id}"
  KMS_replication_ARN            = module.KMS_Encrypt_BCP.KMS_Key_ARN
  Policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::178286397538:user/JenkinsSecret"
            },
            "Action": "s3:Put*",
            "Resource": [
                "arn:aws:s3:::backups-client-latest",
                "arn:aws:s3:::backups-client-latest/*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:Delete*",
            "Resource": [
                "arn:aws:s3:::backups-client-latest",
                "arn:aws:s3:::backups-client-latest/*"
            ]
        }
    ]
}
  POLICY
}

# -----------------
# --- IAM Roles ---
# -----------------

module "IAM_Latest_bcp" {
  source                 = "./Modules/IAM"
  Name                   = "Latest_BCP"
  Origin_Bucket_ARN      = module.S3_Backups_Latest.bucket_arn
  Destination_Bucket_ARN = module.S3_Backups_Latest_bcp.bucket_arn
}

module "IAM_Production_bcp" {
  source                 = "./Modules/IAM"
  Name                   = "Production_BCP"
  Origin_Bucket_ARN      = module.S3_Backups.bucket_arn
  Destination_Bucket_ARN = module.S3_Backups_BCP.bucket_arn
}
