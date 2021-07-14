#### Tray.io Account secrets #### 
module "SecretManagerTrayLatest" {
  source      = "../Modules/SecretManager"
  secret_name = "Tray-aws_trayio-latest"
  retention_time = 30
}
module "SecretManagerTrayPreview" {
  source      = "../Modules/SecretManager"
  secret_name = "Tray-aws_trayio-preview"
  retention_time = 30
}

module "SecretManagerTrayProduction" {
  source      = "../Modules/SecretManager"
  secret_name = "Tray-aws_trayio-production"
  retention_time = 30
}

### Tray.io WORKFLOW Secrets ###

module "SecretManagerTrayExample" {
  source      = "../Modules/SecretManager"
  secret_name = "Tray-example-latest"
  retention_time = 30
}
