########################
#####  Variables  ######
#######################
variable "Name" {
  type = string
}

variable "Policy" {
  default = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [],
            "Resource": []
        }
    ]
}
EOF
}