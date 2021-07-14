## Centralized Secrets

To add secrets go to service file: for example Tray.io secrets are added to `secrets_tray.io.tf`

```
module "SecretManagerTrayExample" {
  source      = "../Modules/SecretManager"
  secret_name = "Tray-example-latest"
  retention_time = 30
}
```

submit merge request. upon approved MR to develop branch changes will be applied in Terraform cloud for the `SS-Secrets-Centralized` workspace