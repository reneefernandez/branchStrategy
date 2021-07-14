#### Services #### 
module "SecretManagerServicesLatest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-services-latest"
  retention_time = 30
}

module "SecretManagerServicesStaging" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-services-staging"
  retention_time = 30
}
module "SecretManagerServicesTest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-services-test"
  retention_time = 30
}

module "SecretManagerServicesPreview" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-services-preview"
  retention_time = 30
}

module "SecretManagerServicesProduction" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-services-production"
  retention_time = 30
}
