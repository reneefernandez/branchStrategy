#***************************
#******** IAM for ECS ******
#***************************

locals {
  secrets_array_local = jsonencode(formatlist("%s", var.ARN_Secrets))
  KMS_key_local       = jsonencode(formatlist("%s", var.KMS_Key))
}

# ----------------------------
# -----      Roles     -------
# ----------------------------


# ---- Role for ECS instances  ----

resource "aws_iam_role" "RoleECS" {
  name               = "ECS-ROLE-${var.Name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name       = "ECS-ROLE-${var.Name}"
    Created_by = "Terraform"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# ---- Cross-Account Role  ----

resource "aws_iam_role" "CrossAccountRole" {
  name               = "CrossAccountRoleDeploy_${var.Name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CrossaccountPolicy",
      "Effect": "Allow",
      "Principal": { "AWS": ["arn:aws:iam::${var.Account_ID_SS}:root"]
    },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF

  tags = {
    Name       = "CrossAccountRoleDeploy_${var.Name}"
    Created_by = "Terraform"
  }
  lifecycle {
    create_before_destroy = true
  }
}


# ----------------------------
# -----   Policies     -----
# ----------------------------

# ---- Policy for CrossAccount Role ----


resource "aws_iam_policy" "policy_assume_role_and_ECS" {
  name        = "policyAssumeRoleECSDeploy${var.Name}"
  description = "policy to grant access to update ECS service "
  lifecycle {
    create_before_destroy = true
  }
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": [
                  "ecs:UpdateService",
                  "ecs:DescribeClusters",
                  "ecs:DescribeServices",
                  "ecs:ListServices"
                  ],
        "Resource": "arn:aws:ecs:us-west-2:${var.Account_ID_Current}:service/*"
    }
    ]
}
EOF

}

# ---- Policy Secret secret manager  ----

resource "aws_iam_policy" "policy_Get_Secret_Manager" {
  count       = "${var.EnableSecretManger == true ? 1 : 0}"
  name        = "Policy_Secret_Manager_ECS_${var.Name}"
  description = "policy to grant access to secrets and set Env variables into Task DEFINITION"
  lifecycle {
    create_before_destroy = true
  }
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": ${local.secrets_array_local}
        }
    ]
}
EOF
}

resource "aws_iam_policy" "policy_Get_Secret_Manager_kms" {
  count       = length(var.KMS_Key) != 0 ? 1 : 0
  name        = "Policy_Secret_Manager_ECS_KMS_${var.Name}"
  description = "policy to grant access to secrets and set Env variables into Task DEFINITION"
  lifecycle {
    create_before_destroy = true
  }
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey"
            ],
            "Resource": ${local.KMS_key_local}
        }
    ]
}
EOF
}

# ----------------------------
# -----   Attachment     -----
# ----------------------------


# ---- Attachment policy for CodeDeploy role ----

resource "aws_iam_role_policy_attachment" "attachment1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = "${aws_iam_role.RoleECS.name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "attachementSecretManagerPolicy" {
  count      = "${var.EnableSecretManger == true ? 1 : 0}"
  policy_arn = "${aws_iam_policy.policy_Get_Secret_Manager[0].arn}"
  role       = "${aws_iam_role.RoleECS.name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "attachementSecretManagerPolicyKMS" {
  count      = length(var.KMS_Key) != 0 ? 1 : 0
  policy_arn = "${aws_iam_policy.policy_Get_Secret_Manager_kms[0].arn}"
  role       = "${aws_iam_role.RoleECS.name}"
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role_policy_attachment" "attachment2" {
  policy_arn = "${aws_iam_policy.policy_assume_role_and_ECS.arn}"
  role       = "${aws_iam_role.CrossAccountRole.name}"
  lifecycle {
    create_before_destroy = true
  }
}
