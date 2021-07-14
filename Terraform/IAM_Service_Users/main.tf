# # # # # # # # # # # # # # # # # #
# # #   Providers - Section   # # #
# # # # # # # # # # # # # # # # # #

provider "aws" {
  profile    = var.Account_Name
  region     = var.Region
}

module "IAM_appcAPI_Prod" {
  source      = "../Modules/IAM_Services"
  Name = var.Secret_Name
  Policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucket",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::appui-content.client.com",
                "arn:aws:s3:::*-services-education-partners/*",
                "arn:aws:s3:::*-services-corporate-partners/*",
                "arn:aws:s3:::*-services-client/*",
                "arn:aws:s3:::appui-content.client.com/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucketMultipartUploads",
                "s3:ListBucket",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::*-services-education-partners",
                "arn:aws:s3:::*-services-corporate-partners",
                "arn:aws:s3:::*-services-client"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObjectVersion",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::appui-content.client.com",
                "arn:aws:s3:::appui-content.client.com/*"
            ]
        }
    ]
}
  EOF
}

