#************************
#***  IAM Resource *****
#************************


# ----------------------------
# -----      Roles     -------
# ----------------------------

# ---- Cross Account Role Shared Services Account ----
resource "aws_iam_role" "CrossAccountRoleSSA" {
  name = "CrossAccountRoleSSA"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CrossaccountPolicy",
      "Effect": "Allow",
      "Principal": { "AWS": [
                      "arn:aws:iam::${var.Latest_Account_ID}:root",
                      "arn:aws:iam::${var.Prod_Account_ID}:root"]
    },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF

  tags = {
    Name = "CrossAccountRoleSSA"
    Created_by = "Terraform"
  }
  lifecycle {
    create_before_destroy = true
}
}

# ---- Role for Lambda Function ----

resource "aws_iam_role" "RoleECSLambda" {
  name = "LambdaRole_Deploy_ECS"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name = "LambdaRole_Deploy_ECS"
    Created_by = "Terraform"
}
  lifecycle {
    create_before_destroy = true
}
}


# ----------------------------
# -----   Policies     -----
# ----------------------------

# ---- Policy to Create Log Group----

resource "aws_iam_policy" "policy_Lambda_role_and_ECS" {
  name        = "policyLambdaRole_to_Register_Logs"
  description = "policy to grant access to update ECS service from lambda "
lifecycle {
  create_before_destroy = true
}
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": "logs:CreateLogGroup",
        "Resource": "arn:aws:logs:us-west-2:${var.SS_Account_ID}:*"
    },
    {
        "Effect": "Allow",
        "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
        ],
        "Resource": [
               "arn:aws:logs:us-west-2:${var.SS_Account_ID}:log-group:/aws/lambda/*:*"
        ]
    },
    {
     "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
              "arn:aws:iam::${var.Prod_Account_ID}:role/CrossAccountRoleDeploy*",
              "arn:aws:iam::${var.Latest_Account_ID}:role/CrossAccountRoleDeploy*"
        ]
    }
    ]
}
EOF
}

resource "aws_iam_policy" "policy_Get_Secrets" {
  name        = "policyGetSecrets"
  description = "policy to grant access to get secret from AWS secret Manager"
lifecycle {
  create_before_destroy = true
}
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": ["arn:aws:secretsmanager:us-west-2:${var.SS_Account_ID}:*"]
    }  
    ]
}
EOF
}


# ----------------------------
# -----   Attachment     -----
# ----------------------------


# ---- Attachment policy for Lambda role ----

resource "aws_iam_role_policy_attachment" "Attachement1" {
  policy_arn = "${aws_iam_policy.policy_Lambda_role_and_ECS.arn}"
  role       = "${aws_iam_role.RoleECSLambda.name}"
}

resource "aws_iam_role_policy_attachment" "Attachement2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = "${aws_iam_role.CrossAccountRoleSSA.id}"
}

resource "aws_iam_role_policy_attachment" "Attachement3" {
  policy_arn = "${aws_iam_policy.policy_Get_Secrets.arn}"
  role       = "${aws_iam_role.CrossAccountRoleSSA.id}"
}