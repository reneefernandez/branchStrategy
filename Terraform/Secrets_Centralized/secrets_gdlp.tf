# Encryption Key

# ---- Get Accounts IDs -----
data "aws_caller_identity" "ID_Current_Account" {}

data "aws_iam_policy_document" "KMS_POLICY_PROD" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.ID_Current_Account.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]

  }
}

data "aws_iam_policy_document" "KMS_POLICY_Latest" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.ID_Current_Account.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]

  }
}

module "KMSTokenizationProdAccount" {
  source     = "../Modules/KMS"
  Key_Name   = "kms-gdlp-production"
  Alias_Name = "alias/kms-gdlp-production"
  Policy     = data.aws_iam_policy_document.KMS_POLICY_PROD.json
}


module "KMSTokenizationLatestAccount" {
  source     = "../Modules/KMS"
  Key_Name   = "kms-gdlp-latest"
  Alias_Name = "alias/kms-gdlp-latest"
  Policy     = data.aws_iam_policy_document.KMS_POLICY_Latest.json
}

# #### GDLP Background #### 

module "SecretManagerGDLPBackgroundLatest" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPBackground-latest"
  retention_time = 30
  kms_Key        = module.KMSTokenizationLatestAccount.KMS_Key
}

module "SecretManagerGDLPBackgroundTest" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPBackground-test"
  retention_time = 30
  kms_Key        = module.KMSTokenizationLatestAccount.KMS_Key
}

module "SecretManagerGDLPBackgroundPreview" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPBackground-preview"
  retention_time = 30
  kms_Key        = module.KMSTokenizationProdAccount.KMS_Key
}

module "SecretManagerGDLPBackgroundProduction" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPBackground-production"
  retention_time = 30
  kms_Key        = module.KMSTokenizationProdAccount.KMS_Key
}

#### GDLPRealtime #### 

module "SecretManagerGDLPRealtimeLatest" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPRealtime-latest"
  retention_time = 30
  kms_Key        = module.KMSTokenizationLatestAccount.KMS_Key
}

module "SecretManagerGDLPRealtimeTest" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPRealtime-test"
  retention_time = 30
  kms_Key        = module.KMSTokenizationLatestAccount.KMS_Key
}

module "SecretManagerGDLPRealtimePreview" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPRealtime-preview"
  retention_time = 30
  kms_Key        = module.KMSTokenizationProdAccount.KMS_Key
}

module "SecretManagerGDLPRealtimeProduction" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-GDLPRealtime-production"
  retention_time = 30
  kms_Key        = module.KMSTokenizationProdAccount.KMS_Key
}
