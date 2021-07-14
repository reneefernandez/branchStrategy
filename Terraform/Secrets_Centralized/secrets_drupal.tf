#### appd #### 
module "SecretManagerappdLatest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appd-latest"
  retention_time = 30
}

module "SecretManagerappdStaging" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appd-staging"
  retention_time = 30
}
module "SecretManagerappdTest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appd-test"
  retention_time = 30
}

module "SecretManagerappdPreview" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appd-preview"
  retention_time = 30
}

module "SecretManagerappdProduction" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appd-production"
  retention_time = 30
}

### holds db password for handling rotation of envs
module "SecretManagerappdRDS" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appd-rds"
  retention_time = 30
}
