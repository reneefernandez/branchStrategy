# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #

# Account where you want to deploy 
provider "aws" {
  profile = var.Account_Name
  region  = var.Region
}

# Virginia region is used to ssl certificate used for CloudFront

provider "aws" {
  profile = var.Account_Name # Change this value for the profile with the credentials where you want to create a LandingPage
  region  = "us-east-1"
  alias   = "virginia"
}

#### Shared Services account
provider "aws" {
  alias   = "ss-account"
  profile = "sharedservices"
  region  = var.Region
}

#### Production account
provider "aws" {
  alias   = "prod-account"
  profile = "production"
  region  = var.Region
}

# # # # # # # # # # # # # # # # #
# # #   Get IDs - Section   # # #
# # # # # # # # # # # # # # # # #

#Get values of reasources already created by other scripts

# ---- Get Accounts IDs -----
data "aws_caller_identity" "ID_Current_Account" {}

data "aws_caller_identity" "ID_SS_Account" {
  provider = aws.ss-account
}



# ---- Route53 Zones ID client.com

data "aws_route53_zone" "main_zone" {
  name     = "client.com."
  provider = aws.prod-account
}

# ---- Route53 Zones ID test.client.com

data "aws_route53_zone" "test_zone" {
  name     = "test.client.com."
  provider = aws.prod-account
}

# ---- Route53 Zones ID latest.client.com

data "aws_route53_zone" "latest_zone" {
  name     = "latest.client.com."
  provider = aws.prod-account
}

# ---- Get Networking IDs -----

# ---- VPC  -----
data "aws_vpc" "vpc" {
  tags = {
    Name = "VPC_client_${var.Account_Name}"
  }
}
# ---- Subnets   -----

# ---- Publics Subnets   -----
data "aws_subnet" "public_subnet1" {
  tags = {
    Name = "Subnet_Public1_${var.Account_Name}"
  }
}

data "aws_subnet" "public_subnet2" {
  tags = {
    Name = "Subnet_Public2_${var.Account_Name}"
  }
}

# ---- Private Subnets   -----
data "aws_subnet" "private_subnet1" {
  tags = {
    Name = "Subnet_Private1_${var.Account_Name}"
  }
}

data "aws_subnet" "private_subnet2" {
  tags = {
    Name = "Subnet_Private2_${var.Account_Name}"
  }
}

# ---- Get Certificates ARNs -----

data "aws_acm_certificate" "Cert_ALBs" {
  domain = (var.on_demand == true ? (var.Account_Name == "production" ? var.Mapping_Certs["on_demand_prod"] : var.Mapping_Certs["on_demand"]) : var.Mapping_Certs[var.Account_Name])
}

data "aws_acm_certificate" "Cert_CDN" {
  domain   = (var.on_demand == true ? (var.Account_Name == "production" ? var.Mapping_Certs["on_demand_prod"] : var.Mapping_Certs["on_demand"]) : var.Mapping_Certs[var.Account_Name])
  provider = aws.virginia
}

# ---- Get Cluster Names ARNs -----

data "aws_ecs_cluster" "cluster" {
    cluster_name = "Cluster-microservices-${var.Environment}"
}

# ---- Random pass for RDS instance-----

resource "random_password" "password" {
  length  = 16
  special = false
}


# # # # # # # # # # # # # # # # # # # # #
# # #    Modules Creation - Section   # #
# # # # # # # # # # # # # # # # # # # # #

# --------------------------------
# --- SecretManager Resources ----
# --------------------------------

# --- Secret for NGINX -----
module "SecretManagerNGINX" {
  source         = "../Modules/SecretManager"
  secret_name    = "Secret-nginx-${var.Environment}"
  retention_time = (var.on_demand == true ? 0 : 30)
}

# ----------------------
# --- IAM Resources ----
# ----------------------

module "IAM" {
  source             = "../Modules/IAM_ECS"
  Name               = "nginx-${var.Environment}"
  ARN_Secrets        = [module.SecretManagerNGINX.Secret_ARN]
  Account_ID_SS      = data.aws_caller_identity.ID_SS_Account.account_id
  Account_ID_Current = data.aws_caller_identity.ID_Current_Account.account_id
  Region             = var.Region
  EnableSecretManger = true
}

# ----------------------
# --- SG Resources ----
# ----------------------

# --- SG for Nginx -----
module "SG_Task_ECS_Nginx" {
  source        = "../Modules/SecurityGroup_ECS"
  Environment   = "nginx-${var.Environment}"
  VPC           = data.aws_vpc.vpc.id
  ContainerPort = 80
}

# ----------------------
# --- Target Groups ----
# ----------------------


# --- TG for Nginx -----

module "Target_Nginx" {
  source           = "../Modules/TargetGroup"
  TG_Name          = "TG-Nginx-${var.Environment}"
  TG_Port          = 80
  VPC              = data.aws_vpc.vpc.id
  Path             = "/health_nginx"
  PortHealthChecks = "80"
  Target_Type      = "ip"
}


# ----------------------
# --- ALB Resources ----
# ----------------------

## Note:  If you want to change the ALB to PRIVATE, please change the subnets too
#         change public to private

resource "random_id" "this" {
  byte_length = "2"
}

#### ALB Public Nginx  ####

module "ALB_Nginx_ECS" {
  source        = "../Modules/ALB_v2"
  Environment   = "Nginx-${var.Environment}"
  Subnets       = (var.Account_Name != "production" && var.Environment != "demo" ? [data.aws_subnet.private_subnet1.id, data.aws_subnet.private_subnet2.id] : [data.aws_subnet.public_subnet1.id, data.aws_subnet.public_subnet2.id])
  SecurityGroup = module.SG_Task_ECS_Nginx.SG_ALB_ID
  VPC           = data.aws_vpc.vpc.id
  Cert_ARN      = data.aws_acm_certificate.Cert_ALBs.arn
  Internal      = var.Account_Name != "production" && var.Environment != "demo"
  AddRule       = var.Account_Name == "production" ? true : false
  Random_Id     = random_id.this.hex
  Target_Group  = module.Target_Nginx.TargetGroup_ARN
  Enable_Logs   = true
}

# ---  Task Definition Nginx ----

module "Task-Definition-Nginx" {
  source          = "../Modules/ECS-TaskDefinition"
  Environment     = "nginx-${var.Environment}"
  TD_Name         = "Nginx-${var.Environment}"
  RoleECS         = module.IAM.ARN_ECS_Role
  CPU             = 256
  Memory          = "512"
  URL_Repo        = "${var.Mapping_ECR_Repos["nginx"]}:${var.Tag_ECR_Image}"
  Region          = var.Region
  ContainerPort   = "80"
  EnableVariables = false
}

#  # ---  ECS Service Nginx ----

module "Service-Nginx" {
  source         = "../Modules/ECS-Service"
  Environment    = "nginx-${var.Environment}"
  NumbeOfTask    = (var.Account_Name == "production" || var.Environment == "appd-demo" ? 2 : 1)
  Region         = var.Region
  SecurityGroup  = module.SG_Task_ECS_Nginx.SG_ECS_Task_ID
  ClusterID      = data.aws_ecs_cluster.cluster.arn
  TargetGroup    = [module.Target_Nginx.TargetGroup_ARN, "null"]
  TaskDefinition = module.Task-Definition-Nginx.ARN_Task_Definition
  Subnets        = [data.aws_subnet.private_subnet1.id, data.aws_subnet.private_subnet2.id]
  ContainerPort  = 80
  ALB            = [module.ALB_Nginx_ECS.ALB_ARN]
}

# # ------------------
# # -- Auto Scaling --
# # ------------------

#---  AutoScaling Nginx ----

module "ECS_Auto_Scaling_Nginx" {
  source       = "../Modules/ECS_Auto_Scaling"
  max_tasks    = 10
  min_tasks    = 2
  cluster_name = data.aws_ecs_cluster.cluster.cluster_name
  service_name = module.Service-Nginx.ServiceName
  Environment  = "ASG-Nginx-${var.Environment}"
}

# ----------------
# -- CloudFront --
# ----------------

/*module "CloudFront_appd" {
  source             = "../Modules/CloudFront"
  Origin_Domain_Name = module.S3_appd.bucket_regional_domain_name
  Origin_Id          = module.S3_appd.bucket_id
  Cert_ARN           = data.aws_acm_certificate.Cert_CDN.arn
  Custom_Domain      = "cdn.${element(split("-", var.Environment), 1)}.client.com"
}
*/
# -----------------
# -- R53 Records --
# -----------------

# --- pointing to dns of the private ALB - appd.<EnvironmentName(freya...)>.client.com ----

# Nginx ALB

module "Route53_NginxALB" {
  source       = "../Modules/Route53"
  HostedZoneId = "Z3S5172K3LEJ3"
  providers = {
    aws = aws.prod-account
  }
  Record_Type       = "A"
  Custom_Domain     = "*.${element(split("-", var.Environment), 1)}.client.com"
  Alias_Name        = module.ALB_Nginx_ECS.ALB_DNS
  Alias_Hosted_Zone = module.ALB_Nginx_ECS.Zone_Id
}
#--- pointing to the DNS of CloudFront distribution - cdn.<EnvironmentName(freya...)>.client.com ------>   ----
/*module "Route53_CloudFront" {
  source        = "app.terraform.io/client-Prod/route53/aws//modules/records"
  version       = "1.3.1"
  ZONE_ID       = data.aws_route53_zone.main_zone.zone_id
  RECORD_NAME   = "cdn.${element(split("-", var.Environment), 1)}.client.com"
  RECORD_TYPE   = "CNAME"
  TTL           = 60
  RECORD_VALUEs = [module.CloudFront_appd.domain_name]
  providers = {
    aws = aws.prod-account
  }
}*/