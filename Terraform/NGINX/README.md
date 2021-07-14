# Terraform for appd

These scripts can be used to deploy the resources for appd, the resources created by scripts are:

- ECS Cluster
- ECS Services, nginx and appd
- Application Load Balancer for appd(private) and Nginx(public)
- IAM Roles
- Security Groups
- RDS instance
- CloudFront Distribution
- S3 bucket to store content


## Usage

You need to clone the repository and select/create the correct Terraform Workspace which you want to create the resources. 

**1.** Clone the repository

**2.** Run Terraform init. Specify the backends configuration that you want to use.
```terraform
terraform init -backend-config=./File_To_Use
```
**Note:** When you run terraform init for the first time, Terraform will ask to you about the workspace that you want to use according to backend configuration, if that happens please omit step 3.

**3.** Select the workspace where you want to deploy, for this case there are three workspaces for each backend config, for the Latest backend you can select between appd-freya, appd-hela and appd-vidar, for the Production backend you can select between appd-loki appd-thor and appd-odin.

```terraform
terraform workspace select Workspace_Name
```

**4.** Run the terraform plan command, feel free if you want to use a tfvars file to specify the variables.
```terraform
terraform plan -var Account_Name="ACCOUNT_NAME(according to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy" -var Tag_ECR_Image="docker image tag to deploy in ecs cluster, apply for nginx and appd"
```

For the variable Environment should use the following structure:
              
    Environment=put here appd-freya, appd-odin or the lower environment to deploy or update
              
   

**Note:** You must specify the tag according to the environment that you want to launch if you No specify a tag, the deploy can start in the different environments causing several issues.

**5.** Verify the plan 

**6.** Run terraform apply
 ```terraform
 terraform apply -var Account_Name="ACCOUNT_NAME(accoring to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy" -var Tag_ECR_Image="docker image tag to deploy in ecs cluster, apply for nginx and appd"
```