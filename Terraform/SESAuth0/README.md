# SIMPLE EMAIL SERVICES FOR AUTH0
 
Check domain and create the necessary records (TXT and CNAME) in route53 to use the AWS SES service with the desired domain
 
## Usage
 
**1.** Clone the repository
 
**2.** Run Terraform init. Specify the backends configuration that you want to use.
```terraform
terraform init -backend-config=./File_To_Use
```
**Note:** When you run terraform init for the first time, Terraform will ask you about the workspace that you want to use according to backend configuration, if that happens please omit step 3.
 
**3.** Select the workspace where you want to deploy, for the Latest backend you can select between appUI-freya, appUI-hela, and appUI-vidar, for the Production backend you can select between appUI-loki, appUI-thor, and appUI-odin.
 
```terraform
terraform workspace select Workspace_Name
```
**4.** Run the terraform plan command,feel free if you want to use a tfvars file to specify the variables.
```terraform
terraform plan -var Account_Name="ACCOUNT_NAME(according to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy"
```

For the variable **Environment** you should use the following structure(without quotation marks):
              
              Environment=SES-AUTH0

**5.** Verify the plan
 
**6.** Run terraform apply
```terraform
terraform apply -var Account_Name="ACCOUNT_NAME(according to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy" 
 ```