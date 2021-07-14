#### appUi #### 
module "SecretManagerappUiLatest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appui-latest"
  retention_time = 30
}

module "SecretManagerappUiStaging" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appui-staging"
  retention_time = 30
}
module "SecretManagerappUiTest" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appui-test"
  retention_time = 30
}

module "SecretManagerappUiPreview" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appui-preview"
  retention_time = 30
}

module "SecretManagerappUiProduction" {
  source      = "../Modules/SecretManager"
  secret_name = "Secret-appui-production"
  retention_time = 30
}

