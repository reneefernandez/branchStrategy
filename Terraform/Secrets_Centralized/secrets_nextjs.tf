#### appJs #### 
module "SecretManagerappJsLatest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appjs-latest"
  retention_time = 30
}

module "SecretManagerappJsStaging" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appjs-staging"
  retention_time = 30
}
module "SecretManagerappJsTest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appjs-test"
  retention_time = 30
}

module "SecretManagerappJsPreview" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appjs-preview"
  retention_time = 30
}

module "SecretManagerappJsProduction" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appjs-production"
  retention_time = 30
}