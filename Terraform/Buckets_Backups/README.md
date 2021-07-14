# Terraform for S3 Buckets to store Backups

This code was created to launch the S3 bucket to store the backups for Production and Latest environment. BCP is also contemplated in this workspace via replication.

Resources to be created
- 2 S3 buckets for Latest (normal backup and BCP)
- 2 S3 buckets for Production (normal backup and BCP)
- IAM resources (roles, policies and attachments)
- KMS (key and alias for BCP)

## Usage

You need to clone the repository and select/create the correct Terraform Workspace where you want to create the resources. 

**1.** Clone the repository

**2.** Run Terraform init. Specify the backends configuration that you want to use.
```terraform
terraform init -backend-config=./backendSS.hcl
```

**Note:** When you run terraform init for the first time, Terraform will ask you about the workspace that you want to use according to backend configuration, if that happens please omit step 3.

**3.** Select the workspace where you want to deploy, the workspace created for this environments is named Buckets
```terraform
terraform workspace select Workspace_Name
```
**Note:** us-east-1 is the region being used for BCP

**4.** Run the terraform plan command
```terraform
terraform plan -var Account_Name="ACCOUNT_NAME(according to profile names in ~/.aws/credentials)" -var Region="Region_used_to_deploy" -var Region_replication="Region_used_for_bcp"
```
**Note:** us-east-1 is the region being used for BCP

**5.** Verify the plan 

**6.** Run terraform apply
 ```terraform
 terraform apply -var Account_Name="ACCOUNT_NAME(accoring to profile names in ~/.aws/credentials)" -var Region="Region_used_to_deploy" -var Region_replication="Region_used_for_bcp"