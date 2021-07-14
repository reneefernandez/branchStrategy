#***********************
#*** IAM Resources *****
#***********************

resource "aws_iam_role" "s3_replication_role" {
  name = "s3_replication_role_${var.Name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "s3_replication_policy" {
  name = "s3_replication_policy_${var.Name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.Origin_Bucket_ARN}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.Origin_Bucket_ARN}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject"
      ],
      "Effect": "Allow",
      "Resource": "${var.Destination_Bucket_ARN}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "s3_replication_attachment" {
  name       = "S3_Replication_Role"
  roles      = ["${aws_iam_role.s3_replication_role.name}"]
  policy_arn = "${aws_iam_policy.s3_replication_policy.arn}"
}