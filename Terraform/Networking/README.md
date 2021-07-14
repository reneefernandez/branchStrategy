# NETWORKING ENVIRONMENT

This code was created to launch the AWS resources to deploy the Networking environment. The code will deploy the following AWS resources:
- VPC
- Subnets
- Route Tables
- NAT and Internet Gateway 

The main.tf script needs a Transit Gateway ID to create Routes Tables to allow communication between account and client VPN.If the Transit Gateway has changed please update the id into main.tf script in the Networking module.


## Usage

You need to clone the repository and select/create the correct Terraform Workspace where you want to create the resources. 

**1.** Clone the repository

**2.** Run Terraform init. Specify the backends configuration that you want to use.
```terraform
terraform init -backend-config=./File_To_Use
```
**Note:** When you run terraform init for the first time, Terraform will ask to you about the workspace that you want to use according to backend configuration, if that happens please omit step 3.

**3.** Select the workspace where you want to deploy
```terraform
terraform workspace select Workspace_Name
```
**4.** Run the terraform plan command
```terraform
terraform plan -var Account_Name="ACCOUNT_NAME(according to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy" 
```
Example of $ENV_NAME = latest
     
**5.** Verify the plan 

**6.** Run terraform apply
 ```terraform
 terraform apply -var Account_Name="ACCOUNT_NAME(accoring to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy" 
  ```