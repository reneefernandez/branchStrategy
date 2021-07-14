# Shared Resources used by Landing Pages Environment
 
This code was created to launch the some AWS resources that other environments use, resources like Cross Account Role, AWS Secret Manager to store credentials and the ECR repositories to store the Docker images.
 
## Usage
 
You need to clone the repository and select/create the correct Terraform Workspace where you want to create the resources.
 
**1.** Clone the repository
 
**2.** Run Terraform init. Specify the backends configuration that you want to use.
```terraform
terraform init -backend-config=./backendSS.hcl
```
**Note:** When you run terraform init for the first time, Terraform will ask you about the workspace that you want to use according to backend configuration, if that happens please omit step 3.
 
**3.** Select the workspace where you want to deploy
```terraform
terraform workspace select Workspace_Name
```
**4.** Run the terraform plan command
```terraform
terraform plan -var Account_Name="ACCOUNT_NAME(according to profiles name in ~/.aws/credentials)" -var Region="Region_used_to_deploy"
```
   
**5.** Verify the plan
 
**6.** Run terraform apply
```terraform
terraform apply -var Account_Name="ACCOUNT_NAME(according to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy"
 ```
