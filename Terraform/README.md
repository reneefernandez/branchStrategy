# Terraform client Project

## General Steps
The project has different folders that contain Terraform code to launch a specific service. There are general steps that you must to follow to launch the resources.

Before to launch a resource you need to have in mind  the following:

  - Install terraform, use Terraform v0.12.13, you can download it here 
     https://releases.hashicorp.com/terraform/0.12.13/
  - Configure your Terraform token to use organizations and store the state in Terraform Enterprise https://client.atlassian.net/wiki/x/-QAaAw
  - Configure the AWS credentials into your laptop(for Linux  ~/.aws/credentials), you need to use the following format:

            [latest]
            aws_access_key_id = Replace_for_correct_Access_Key
            aws_secret_access_key = Replace_for_correct_Secret_Key

            [sharedservices]
            aws_access_key_id = Replace_for_correct_Access_Key
            aws_secret_access_key = Replace_for_correct_Access_Key

            [production]
            aws_access_key_id= Replace_for_correct_Access_Key
            aws_secret_access_key= Replace_for_correct_Access_Key

       If you have more AWS profiles feel free to add them.

## Code structure

Each folder is named according to the service or environment that will launch. Into each folder you will find the following files:

  - **main.tf:** This is the principal Terraform script, where the modules created are called. Each AWS resource launched is parametrized and created by this script, here you define the names and set some attributes that the modules need.
  - **variables.tf:** In this file, you can find the variables used for the main.tf script, some variables have default values that you can change, the variables Account_Name, Environment, on_demand, and Region have not to default value and you must specify to launch code. The values of these variables specify the AWS account(AWS Profile), AWS Region, and Environment Name with the resources that will be identified. The on_demand variable is used to specify if the environment to launch is on-demand or no, the default value is false, Ansible scripts set the parameters internally, please avoid setting the value to true.
  - **outputs.tf:** This file is used to export some attributes of resources created like DNS of ALBs, ARNs, Endpoints, etc. These values can be used for other modules.
  - **backend.tf:** This file has a basic backend configuration used to specify that the Terraform states will be stored remotely. The project uses Terraform Workspace and stores the state in Terraform Enterprise, because that you need to specify the Terraform Organization name and the prefix for the workspace. There are two files with these values already configured, you only need to specify the correct file when you run terraform init, this makes easier the process to launch new changes because you don't need to modify any file.
  
                terraform init -backend-config=./File_To_Use
                
  - **backendLatest.hcl:** This file contains the configuration to use the Terraform Organization for Production and set the Latest prefix, please use this file when you want to launch resources in the Latest account.
  - **backendProd.hcl:** This file contains the configuration to use the Terraform Organization for Production and set the Prod prefix, please use this file when you want to launch resources in the Production account.
  
## Terraform Modules

Terraform Modules are used to define multiple resources that are used together, for this case some environments use some common resources like ALB, ECS cluster, etc. The Modules folder contains the Global Modules created for some services, these modules have been created to set parameters according to the environment to deploy. Each service consumes a specific module and sets some parameters to enable or disable features into the module, for instance, enable or disable the Listener rules in ALB Module or enable or disable secret manager into ECS Clusters.

There are some modules that were created in the same folder in which stored the service, that is because currently there are some dependencies that can't move to Global Modules.

## Usage

You need to clone the repository and select/create the correct Terraform Workspace where you want to create the resources. 

**1.** Clone the repository and move to the folder that you want to use.

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
terraform plan -var Account_Name="ACCOUNT_NAME(according to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME" -var Region="Region_used_to_deploy"
```
**Note:** some services need other parameters to be launch, please read the documentation into each folder.
     
**5.** Verify the plan 

**6.** Run terraform apply
 ```terraform
 terraform apply -var Account_Name="ACCOUNT_NAME(accoring to profiles name in ~/.aws/credentials)"  -var Environment="ENV_NAME"  -var Region="Region_used_to_deploy"
  ```
