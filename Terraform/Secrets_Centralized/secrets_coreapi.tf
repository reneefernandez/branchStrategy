#### appcApi #### 
module "SecretManagerappcApiLatest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appcapi-latest"
  retention_time = 30
}

module "SecretManagerappcApiStaging" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appcapi-staging"
  retention_time = 30
}
module "SecretManagerappcApiTest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appcapi-test"
  retention_time = 30
}

module "SecretManagerappcApiPreview" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appcapi-preview"
  retention_time = 30
}

module "SecretManagerappcApiProduction" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appcapi-production"
  retention_time = 30
}