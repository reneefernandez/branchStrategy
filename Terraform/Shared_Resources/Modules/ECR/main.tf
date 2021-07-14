#************************
#***  ECR Resource *****
#************************


# ---- ECR repository ----
resource "aws_ecr_repository" "ECR_Repository" {
  name = "${var.NameRepo}"
}


# ----Policy fot the repository ----
resource "aws_ecr_repository_policy" "ECR_Repository_Policy" {
  repository = "${aws_ecr_repository.ECR_Repository.name}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::980422662115:root",
                    "arn:aws:iam::732909921855:root",
                    "arn:aws:iam::615051968397:root"
                ]
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:ListImages"
            ]
        }
    ]
}
EOF
}

