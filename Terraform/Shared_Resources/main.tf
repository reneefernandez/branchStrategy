# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #

provider "aws" {
  profile    = "${var.Account_Name}"
  region     = "${var.Region}"
}

# Production provider

provider "aws" {
  profile    = "production"  
  region     = "${var.Region}"
  alias      = "prod-account"
}

# Latest provider
provider "aws" {
  profile    = "latest"
  region     = "${var.Region}"
  alias = "latest-account"
}


# # # # # # # # # # # # # # # # #
# # #   Get IDs - Section   # # #   
# # # # # # # # # # # # # # # # #

#Get values of reasources already created by other scripts

# ---- Get Accounts IDs -----
data "aws_caller_identity" "Latest_Account_ID" {
  provider = "aws.latest-account"
}

data "aws_caller_identity" "Prod_Account_ID" {
  provider = "aws.prod-account"
}

data "aws_caller_identity" "SS_Account_ID" {}


# # # # # # # # # # # # # # # # # # # # # 
# # #    Modules Creation - Section   # # 
# # # # # # # # # # # # # # # # # # # # #


# --------------------------------
# --- Secret Manager Resources ---
# -------------------------------


# ------------------------
# --- Secrets appd   ---
# ------------------------

# --- Secret Manager for appd Latest ---

# --- Secret Manager for Latest-A ---

module "SecretManagerLandingPageLatestA" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-latest-a"
}

# --- Secret Manager for Latest-B ---

module "SecretManagerLandingPageLatestB" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-latest-b"
}

# --- Secret Manager for Latest-B ---

module "SecretManagerB" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-latest-B"
}

# --- Secret Manager for Latest Hela ---
module "SecretManagerLandingPagehela" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-hela"
}

# --- Secret Manager for Latest Freya ---
module "SecretManagerLandingPagefreya" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-freya"
}

# --- Secret Manager for Latest Vidar ---

module "SecretManagerLandingPagevidar" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-vidar"
}

# --- Secret Manager for appd Production ---

# --- Secret Manager for Odin ---

module "SecretManagerLandingPageOdin" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-odin"
}

# --- Secret Manager for thor ---
module "SecretManagerLandingPageThor" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-thor"
}

# --- Secret Manager for Loki ---
module "SecretManagerLandingPageloki" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLP-loki"
}

# ------------------------
# --- Secrets LeadAPI  ---
# ------------------------

# --- Secret Manager for LeadAPI Production ---

module "SecretManagerProdLeadAPI" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLeadAPI-Prod"
}

# --- Secret Manager for LeadAPI Latest ---


module "SecretManagerLatestLeadAPI" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretLeadAPI-Latest"
}

# ------------------------
# --- Secrets appUI  ---
# ------------------------

# --- Secret Manager for appUI Latest ---


# --- Secret Manager for appUI Prod ---

module "SecretManagerProdappUIThor" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretappUI-Prod-Thor"
}

module "SecretManagerProdappUIOdin" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretappUI-Prod-Odin"
}


# ------------------------
# --- Secrets appcAPI  ---
# ------------------------

module "SecretManagerLatestServices" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretServices-Latest"
}

# ------------------------
# --- Secrets MongoAPI - LATEST ---
# ------------------------

module "SecretManagerMongoAtlasLatest" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretMongoAtlas-Latest"
}

# ------------------------
# --- Secrets MongoAPI - Prod ---
# ------------------------

module "SecretManagerMongoAtlasProd" {
  source      = "./Modules/SecretManager"
  secret_name = "SecretMongoAtlas-Prod"
}


# ---------------------
# --- IAM Resources ---
# ---------------------

# --- Secret Manager for Latest-A --- ---

module "IAM" {
  source     = "./Modules/IAM"
  Latest_Account_ID  = "${data.aws_caller_identity.Latest_Account_ID.account_id}"
  Prod_Account_ID    = "${data.aws_caller_identity.Prod_Account_ID.account_id}"
  SS_Account_ID      = "${data.aws_caller_identity.SS_Account_ID.account_id}"
}

# ---------------------
# --- ECR Resources ---
# ---------------------

module "ECR_Nginx" {
  source   = "./Modules/ECR"
  NameRepo = "lp_nginx"
}

module "ECR_appd" {
  source   = "./Modules/ECR"
  NameRepo = "lp_appd"
}

module "ECR_appUI" {
  source   = "./Modules/ECR"
  NameRepo = "appui"
}

module "ECR_SERVICES" {
  source   = "./Modules/ECR"
  NameRepo = "client-services"
}

module "ECR_REACT" {
  source   = "./Modules/ECR"
  NameRepo = "client-ssr"
}
